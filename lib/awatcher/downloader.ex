defmodule Awatcher.Downloader do
  require HTTPoison.Retry

  def download(url) do
    HTTPoison.get(url)
    |> HTTPoison.Retry.autoretry(max_attempts: 5, wait: 5_000, include_404s: false, retry_unknown_errors: false)
    |> handle_response()
  end

  def handle_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404, request_url: url}} ->
        raise("Source not found: #{url}")
      {:error, %HTTPoison.Error{reason: reason}} ->
        raise("Request failed: #{reason}")
    end
  end
end
