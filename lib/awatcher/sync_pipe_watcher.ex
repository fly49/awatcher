defmodule Awatcher.SyncPipe.Watcher do
  use GenServer
  alias Awatcher.{HttpClient, Parser, Records, SyncPipe}
  import Awatcher.SyncFunctions, only: [assign_topics: 2]

  def start_link(interval) do
    GenServer.start_link(__MODULE__, interval, name: __MODULE__)
  end

  @ets_name :libraries
  @ets_opts [:set, :public, :named_table, read_concurrency: true]
  def init(interval) do
    # ETS is used for library create/update checking,
    # avoiding redundant SQL queries
    :ets.new(@ets_name, @ets_opts)

    # start GenStage pipe: Producer -> ConsumerSupervisor -> [Task, ...]
    {:ok, producer} = SyncPipe.DataProvider.start_link([])
    {:ok, _} = SyncPipe.LibraryMakerSupervisor.start_link(@ets_name)

    # state: %{interval: integer(), producer: pid(), timer: reference()}
    state = %{interval: interval, producer: producer}
    {:ok, schedule_sync(state)}
  end

  def start_sync_now do
    Process.send(__MODULE__, :sync, [:noconnect])
  end

  def remaining_time do
    GenServer.call(__MODULE__, :remaining_time)
  end

  def handle_call(:remaining_time, _from, state) do
    time = Process.read_timer(state.timer)
    {:reply, time, state}
  end

  # Takes state and returns updated one with new timer
  defp schedule_sync(state) do
    if state[:timer] do
      Process.cancel_timer(state.timer)
    end
    timer = Process.send_after(__MODULE__, :sync, state.interval)

    Map.merge(state, %{timer: timer})
  end

  def handle_info(:sync, state) do
    perform_sync(state)
    {:noreply, schedule_sync(state)}
  end

  # File is downloaded from raw domain to not bother with base64 decoding
  @url "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"
  def perform_sync(state) do
    data =
      HttpClient.get(@url)
      |> Parser.parse()
      # list_topics() is used for topic create/update checking,
      # avoiding redundant SQL queries
      |> assign_topics(Records.list_topics())

    fill_ets(Records.list_libraries)
    # Push data as events to producer
    # Dispatching between stages is started automatically by BrodadcastDispatcher
    :ok = GenServer.call(state.producer, {:add_events, data})
  end

  defp fill_ets(data) do
    true = :ets.delete_all_objects(@ets_name)
    true = :ets.insert(@ets_name,
      Enum.map(data, fn lib -> {lib.name, lib} end)
    )
  end
end
