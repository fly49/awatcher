defmodule AwatcherWeb.PageController do
  use AwatcherWeb, :controller

  def index(conn, params) do
    topics = Awatcher.Records.list_topics_with_libraries(params["min_stars"])
    render(conn, "index.html", topics: topics)
  end

  def sync(conn, _) do
    Awatcher.SyncPipe.Watcher.start_sync_now()
    render(conn, "sync.json")
  end
end
