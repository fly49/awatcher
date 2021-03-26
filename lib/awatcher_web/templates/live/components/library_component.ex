defmodule AwatcherWeb.LibraryComponent do
  use AwatcherWeb, :live_component

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <p>
      <a href="<%= @library.url %>" class="text-success"><%= @library.name %></a>
      <span><%= live_component(@socket, AwatcherWeb.StarsComponent, stars: @library.stars) %></span>
      <span><%= live_component(@socket, AwatcherWeb.LastCommitComponent, last_commit: @library.last_commit) %></span>
      <span><%= live_component(@socket, AwatcherWeb.DescriptionComponent, description: @library.description) %></span>
    </p>
    """
  end
end
