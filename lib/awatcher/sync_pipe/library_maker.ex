defmodule Awatcher.SyncPipe.LibraryMaker do
  alias Awatcher.Github
  import Awatcher.SyncFunctions, only: [process_library: 2]
  require Logger

  def start_link(ets_name, lib_map) do
    Task.start_link(fn ->
      %{url: url} = lib_map
      github_data = fetch_github_data(url)

      lib_attrs = Map.merge(lib_map, github_data)

      case process_library(lib_attrs, ets_name) do
        {:ok, _} -> :ok
        {:error, changeset} -> Logger.error inspect(changeset)
      end
    end)
  end

  defp fetch_github_data(url) do
    case Regex.match?(~r/https:\/\/github.com\//, url) do
      true ->
        Github.fetch_data(url)
      false ->
        Logger.debug("Non github url: #{url}")
        %{}
    end
  end
end
