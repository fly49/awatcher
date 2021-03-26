defmodule AwatcherWeb.LastCommitComponent do
  use AwatcherWeb, :live_component
  alias Awatcher.Records.Library

  def mount(_params, _session, socket) do
    last_commit = format_last_commit(socket.assigns.last_commit)
    {:ok, assign(socket, last_commit: last_commit)}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    last_commit = format_last_commit(socket.assigns.last_commit)
    {:ok, assign(socket, last_commit: last_commit)}
  end

  def render(assigns) do
    ~L"""
    <button class="button clear icon-only">
      <sub><%= @last_commit %></sub><img src="https://icongr.am/fontawesome/clock-o.svg?size=16&color=4ed138" alt="last commit">
    </button>
    """
  end

  def format_last_commit(nil) do
    ""
  end
  def format_last_commit(date) do
    date
    |> DateTime.diff(DateTime.utc_now(), :second)
    |> div(60*60*24)
    |> abs
  end
end
