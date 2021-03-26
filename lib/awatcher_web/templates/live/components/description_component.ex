defmodule AwatcherWeb.DescriptionComponent do
  use AwatcherWeb, :live_component
  alias Awatcher.Records.Library

  def mount(_params, _session, socket) do
    description = format_description(socket.assigns.description)
    {:ok, assign(socket, description: description)}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    description = format_description(socket.assigns.description)
    {:ok, assign(socket, description: description)}
  end

  def render(assigns) do
    ~L"""
    —
    &nbsp;
    <%= raw(@description) %>
    """
  end

  @regex ~r/\[(.*?)\]\((.*?)\)/
  def format_description(description) do
    case Regex.run(@regex, description) do
      [_match, name, url] ->
        html_url = "<a href=\"#{url}\" class=\"text-success\">#{name}</a>"
        Regex.replace(@regex, description, html_url)
      _ ->
        description
    end
  end
end
