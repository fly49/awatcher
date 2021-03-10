defmodule Awatcher.Github do
  use HTTPoison.Base
  use Retry
  import Stream

  @expected_fields ~w(
    stargazers_count pushed_at
  )

  def fetch_data(url) do
    retry with: linear_backoff(500, 2) |> take(3) do
      get!(url) |> handle_response()
    after
      response -> response
    else
      error -> raise(error)
    end
  end

  def handle_response(response) do
    case response do
      %HTTPoison.Response{status_code: 200, body: body} ->
        body
      %HTTPoison.Response{status_code: 404, request_url: url} ->
        raise("Source not found: #{url}")
    end
  end

  def process_request_url(url) do
    [_, url_tail] = Regex.run(~r/([^\/]+\/[^\/]+)$/, url)
    "https://api.github.com/repos/" <> url_tail
  end

  def process_request_headers(headers) do
    Keyword.put(headers, :user, "fly49:47f2ad3b1bcfcb9b729247ff53560bf064d6cffb")
  end

  def process_response_body(body) do
    body
    |> Jason.decode!
    |> Map.take(@expected_fields)
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end
end
