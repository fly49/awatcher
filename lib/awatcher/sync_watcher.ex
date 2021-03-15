defmodule Awatcher.SyncWatcher do
  use GenServer
  alias Awatcher.{HttpClient, Parser, Records, SyncPipe}
  import Awatcher.SyncFunctions, only: [assign_topics: 2, process_topic: 3]

  @ets_name :libraries
  @ets_opts [:set, :public, :named_table, read_concurrency: true]

  def start_link(interval) do
    GenServer.start_link(__MODULE__, interval, name: __MODULE__)
  end

  def init(interval) do
    :ets.new(@ets_name, @ets_opts)

    {:ok, producer} = SyncPipe.DataProvider.start_link([])
    {:ok, _} = SyncPipe.LibraryMakerSupervisor.start_link(@ets_name)

    schedule_sync(interval)

    {:ok, %{interval: interval, producer: producer}}
  end

  def start_sync do
    Process.send(__MODULE__, :sync, [:noconnect])
  end

  defp schedule_sync(interval) do
    Process.send_after(__MODULE__, :sync, interval)
  end

  @url "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"
  def handle_info(:sync, state) do
    data =
      HttpClient.get(@url)
      |> Parser.parse()
      |> assign_topics(Records.list_topics())

    :ok = prepare_ets(Records.list_libraries, @ets_name)

    :ok = GenServer.call(state.producer, {:add_events, data})
    {:noreply, state}
  end

  defp prepare_ets(data, ets_name) do
    :ets.delete_all_objects(ets_name)
    Enum.each(data, fn lib ->
      :ets.insert(@ets_name, {lib.name, lib})
    end)
    :ok
  end
end
