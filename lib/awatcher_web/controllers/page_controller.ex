defmodule AwatcherWeb.PageController do
  use AwatcherWeb, :controller

  def index(conn, params) do
    topics = Awatcher.Records.list_topics(params["min_stars"])
    render(conn, "index.html", topics: topics)
  end
end
