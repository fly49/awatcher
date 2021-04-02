defmodule Awatcher.SyncPipe.Watcher do
  use GenServer
  alias Awatcher.{SyncPipe, DataMapper}

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
    data = DataMapper.prepare_data(@ets_name)

    # Push data as events to producer
    # Dispatching between stages is started automatically by BrodadcastDispatcher
    :ok = GenServer.call(state.producer, {:add_events, data})

    {:noreply, schedule_sync(state)}
  end
end
