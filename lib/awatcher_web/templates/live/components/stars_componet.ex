defmodule AwatcherWeb.StarsComponent do
  use AwatcherWeb, :live_component
  alias Awatcher.Records.Library

  def mount(_params, _session, socket) do
    stars = format_stars(socket.assigns.stars)
    {:ok, assign(socket, stars: stars)}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    stars = format_stars(socket.assigns.stars)
    {:ok, assign(socket, stars: stars)}
  end

  def render(assigns) do
    ~L"""
    <button class="button clear icon-only">
      <sub><%= @stars %></sub>
      <img src="https://icongr.am/fontawesome/star.svg?size=15&color=4ed138" alt="stars">
    </button>
    """
  end

  def format_stars(nil) do
    ""
  end
  def format_stars(stars) do
    stars
  end
end
