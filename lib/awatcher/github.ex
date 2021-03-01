defmodule GitHub do
  use HTTPoison.Base

  @expected_fields ~w(
    stargazers_count pushed_at
  )

  def process_request_url(url) do
    "https://api.github.com/repos/" <> url
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
