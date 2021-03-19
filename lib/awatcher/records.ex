defmodule Awatcher.Records do
  import Ecto.Query, warn: false
  alias Awatcher.Repo
  alias Awatcher.Records.Library
  alias Awatcher.Records.Topic

  def create_library(attrs) do
    %Library{}
    |> Library.changeset(attrs)
    |> Repo.insert()
  end

  def update_library(%Library{} = library, attrs) do
    library
    |> Library.changeset(attrs)
    |> Repo.update()
  end

  def create_topic(attrs) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  def list_topics() do
    Repo.all(Topic)
  end

  def list_topics_with_libraries(min_stars \\ nil) do
    from(t in Topic)
    |> join(:inner, [t], lib in assoc(t, :libraries))
    |> maybe_sort_by_stars(min_stars)
    |> preload([t, lib], libraries: lib)
    |> order_by([t, lib], asc: t.name, asc: lib.name)
    |> Repo.all()
  end

  defp maybe_sort_by_stars(query, nil) do
    query
  end
  defp maybe_sort_by_stars(query, min_stars) do
    where(query, [t, lib], lib.stars >= ^min_stars)
  end

  def list_libraries do
    Repo.all(Library) |> Repo.preload(:topic)
  end

  def get_topic_by(params) do
    Repo.get_by(Topic, params)
  end

  def get_library_by(params) do
    Repo.get_by!(Library, params)
    |> Repo.preload(:topic)
  end
end
