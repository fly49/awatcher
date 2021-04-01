defmodule Awatcher.SyncPipeWatcherTest do
  use ExUnit.Case, async: true

  test "watcher starts on application initialization and is supervised" do
    children = Supervisor.which_children(Awatcher.Supervisor)

    assert Enum.find(children, fn proc_tuple ->
      elem(proc_tuple, 0) == Awatcher.SyncPipe.Watcher
    end)
  end

  test "ets 'libraries' is created on on initialization" do
    assert :ets.whereis(:libraries) != :undefined
  end

  test "watcher initializes genstage pipe" do
    producer = Process.whereis(Awatcher.SyncPipe.DataProvider)
    consumer_supervisor = Process.whereis(Awatcher.SyncPipe.LibraryMakerSupervisor)
    watcher = Process.whereis(Awatcher.SyncPipe.Watcher)

    watcher_links = Process.info(watcher)[:links]

    assert Enum.member?(watcher_links, producer)
    assert Enum.member?(watcher_links, consumer_supervisor)
  end

  test "schedules next sync on init" do
    assert is_integer(Awatcher.SyncPipe.Watcher.remaining_time)
  end
end
