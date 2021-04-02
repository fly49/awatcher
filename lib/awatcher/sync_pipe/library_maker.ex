defmodule Awatcher.SyncPipe.LibraryMaker do
  alias Awatcher.Records
  require Logger

  def start_link(ets_name, lib_map) do
    Task.start_link(fn ->
      make_library(ets_name, lib_map)
    end)
  end

  def make_library(ets_name, lib_map) do
    lib_map
    |> fetch_github_data()
    |> create_or_update_library(ets_name)
    |> case do
      {:ok, lib} -> lib
      {:error, changeset} -> Logger.error inspect(changeset)
    end
  end

  @github_client Application.get_env(:awatcher, :github_client)
  def fetch_github_data(%{url: url} = lib_map) do
    case @github_client.fetch_data(url) do
      %{pushed_at: last_commit, stargazers_count: stars} ->
        Map.merge(lib_map, %{last_commit: last_commit, stars: stars})
      {:error, reason} ->
        Logger.info(reason)
        lib_map
    end
  end

  def create_or_update_library(%{name: lib_name} = lib_attrs, ets_name) do
    case :ets.lookup(ets_name, lib_name) do
      [ {^lib_name, %Records.Library{} = lib} ] ->
        Records.update_library(lib, lib_attrs)
      [] ->
        Records.create_library(lib_attrs)
      _ ->
        raise("ETS #{ets_name} has duplicates")
    end
  end
end
