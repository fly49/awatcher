defmodule AwatcherWeb.PageLive do
  use Phoenix.LiveView
  alias Awatcher.Records.Library

  def mount(_params, _session, socket) do
    topics = Awatcher.Records.list_topics_with_libraries()
    {:ok, assign(socket, :topics, topics)}
  end

  def handle_event("update", params, socket) do
    topics = Awatcher.Records.list_topics_with_libraries(params["ref"])
    {:noreply, assign(socket, :topics, topics)}
  end
end
