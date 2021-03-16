defmodule AwatcherWeb.PageController do
  use AwatcherWeb, :controller

  def index(conn, _params) do
    topics = Awatcher.Records.list_topics()
    render(conn, "index.html", topics: topics)
  end
end
