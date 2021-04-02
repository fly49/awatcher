defmodule Awatcher.SyncPipe.LibraryMaker do
  import Awatcher.SyncFunctions, only: [process_library: 2]
  require Logger

  @github_client Application.get_env(:awatcher, :github_client)
  def start_link(ets_name, lib_map) do
    Task.start_link(fn ->
      make_library(ets_name, lib_map)
    end)
  end

  def make_library(ets_name, %{url: url} = lib_map) do
    lib_attrs =
      case @github_client.fetch_data(url) do
        %{pushed_at: last_commit, stargazers_count: stars} ->
          Map.merge(lib_map, %{last_commit: last_commit, stars: stars})
        {:error, reason} ->
          Logger.info(reason)
          lib_map
      end

    case process_library(lib_attrs, ets_name) do
      {:ok, lib} -> lib
      {:error, changeset} -> Logger.error inspect(changeset)
    end
  end
end
