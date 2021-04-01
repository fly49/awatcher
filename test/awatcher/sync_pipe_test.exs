defmodule Awatcher.SyncPipeTest do
  use Awatcher.DataCase, async: false
  import Mox

  setup :verify_on_exit!
  setup :set_mox_from_context
  setup do
    # Explicitly get a connection before each test
    # :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    # Setting the shared mode must be done only after checkout
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  test "fetch data from github and build library" do
    %Awatcher.Records.Topic{id: topic_id} = topic_fixture()
    lib_attrs = %{name: "lib", url: "https://github.com/test", description: "desc", topic_id: topic_id}
    {:ok, date, _} = DateTime.from_iso8601("2021-03-19T09:48:40Z")

    expect(Awatcher.GithubMock, :fetch_data, fn _ ->
      %{
        pushed_at: date,
        stargazers_count: 1
      }
    end)

    producer_pid = Process.whereis(Awatcher.SyncPipe.DataProvider)

    assert :ok == GenServer.call(producer_pid, {:add_events, [lib_attrs]})
    :timer.sleep(100)
    assert lib = Awatcher.Records.get_library_by(name: "lib")
    assert lib.url == lib_attrs.url
    assert lib.description == lib_attrs.description
    assert lib.topic_id == lib_attrs.topic_id
    assert lib.stars == 1
    assert lib.last_commit == date
  end
end
