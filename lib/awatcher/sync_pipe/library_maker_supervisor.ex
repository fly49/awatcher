defmodule Awatcher.SyncPipe.LibraryMakerSupervisor do
  use ConsumerSupervisor
  alias Awatcher.SyncPipe.{LibraryMaker, DataProvider}

  @opts [
    strategy: :one_for_one,
    subscribe_to: [{DataProvider, max_demand: 1000, min_demand: 1}],
    max_restarts: 3,
    max_seconds: 30
  ]

  def start_link(ets_name) do
    ConsumerSupervisor.start_link(__MODULE__, [ets_name], name: __MODULE__)
  end

  def init(ets_name) do
    children =[%{id: LibraryMaker, start: {LibraryMaker, :start_link, ets_name}, restart: :transient}]

    ConsumerSupervisor.init(children, @opts)
  end
end
