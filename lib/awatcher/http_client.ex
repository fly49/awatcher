defmodule Awatcher.HttpClient do
  use Retry
  import Stream

  def get(url) do
    retry with: linear_backoff(500, 2) |> take(3) do
      HTTPoison.get(url, [], follow_redirect: true) |> handle_response()
    after
      response -> response
    else
      error -> raise(error)
    end
  end

  def handle_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404, request_url: url}} ->
        raise("Source not found: #{url}")
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        raise("Unexpected status: #{status} with body: #{body}")
      {:error, %HTTPoison.Error{reason: reason}} ->
        raise(reason)
    end
  end
end
