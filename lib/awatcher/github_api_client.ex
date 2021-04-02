defmodule Awatcher.GithubClient do
  @callback fetch_data(String.t()) :: map() | {:error, String.t()}
end

defmodule Awatcher.GithubApiClient do
  @behaviour Awatcher.GithubClient
  use HTTPoison.Base
  use Retry
  import Stream

  @credentials "Zmx5NDk6NzE3N2QwOWM1MjEwZjkzOWI2NjJiOTYxYTU5MzJiY2I0ZTFiMTEwZA=="
  @expected_fields ~w(
    stargazers_count pushed_at
  )

  def fetch_data(url) do
    case valid_url?(url) do
      true ->
        retry with: linear_backoff(500, 2) |> take(3), atoms: [nil] do
          get(url, [], [follow_redirect: true, pool: :github_pool])
          |> handle_response()
        after
          response -> response
        else
          error -> raise(error)
        end
      false ->
        {:error, "Non github url: #{url}"}
    end
  end

  def handle_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404, request_url: url}} ->
        {:error, "Source not found: #{url}"}
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "Unexpected status: #{status} with body: #{body}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        raise(reason)
    end
  end

  def process_request_url(url) do
    [_, url_tail] = Regex.run(~r/([^\/]+\/[^\/]+)\/?$/, url)
    "https://api.github.com/repos/" <> url_tail
  end

  def process_request_headers(headers) do
    Keyword.put(headers, :Authorization, "Basic #{@credentials}")
  end

  def process_response_body(body) do
    body
    |> Jason.decode!
    |> Map.take(@expected_fields)
    |> parse()
    |> Enum.into(%{})
  end

  defp parse(map) do
    Enum.map(map, fn({k,v}) ->
      {String.to_atom(k), parse_time(k, v)}
    end)
  end

  defp parse_time(key, val) do
    case Regex.match?(~r/^\w+_at$/, key) do
      true ->
        {:ok, datetime, _} = DateTime.from_iso8601(val)
        datetime
      false ->
        val
    end
  end

  defp valid_url?(url) do
    Regex.match?(~r/https:\/\/github.com\//, url)
  end
end
