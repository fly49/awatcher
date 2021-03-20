defmodule AwatcherWeb.PageView do
  alias Awatcher.Records.Library
  use AwatcherWeb, :view

  def render("sync.json", _) do
    %{response: "ok"}
  end

  def stars(%Library{stars: nil}) do
    ""
  end
  def stars(%Library{stars: stars}) do
    render("_stars.html", stars: stars)
  end

  def last_commit(%Library{last_commit: nil}) do
    ""
  end
  def last_commit(%Library{last_commit: date}) do
    render("_last_commit.html", date: last_commit_diff(date))
  end

  defp last_commit_diff(date) do
    date
    |> DateTime.diff(DateTime.utc_now(), :second)
    |> div(60*60*24)
    |> abs
  end

  def description(%Library{description: description}) do
    render("_description.html", description: format_description(description))
  end
  @regex ~r/\[(.*?)\]\((.*?)\)/
  defp format_description(description) do
    case Regex.run(@regex, description) do
      [_match, name, url] ->
        html_url = "<a href=\"#{url}\" class=\"text-success\">#{name}</a>"
        Regex.replace(@regex, description, html_url)
      _ ->
        description
    end
  end
end
