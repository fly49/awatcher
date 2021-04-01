defmodule Awatcher.SyncPipe.DataProvider do
  use GenStage

  def start_link(init_data) do
    GenStage.start_link(__MODULE__, init_data, name: __MODULE__)
  end

  def init(init_data) do
    {:producer, init_data, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:add_events, events}, _from, state) do
    {:reply, :ok, events, state}
  end

  def handle_demand(_demand, state) do
    # We don't care about the demand
    {:noreply, [], state}
  end
end
