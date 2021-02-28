defmodule Awatcher.Records do
  import Ecto.Query, warn: false
  alias Awatcher.Repo
  alias Awatcher.Records.Library
  alias Awatcher.Records.Topic

  def create_records(list_of_maps) do
    existed_topics = list_topics()
    existed_libs = list_libraries()
    Enum.each(list_of_maps, fn(map) ->
      %{topic: topic_name, topic_desc: topic_desc, libraries: libraries} = map

      {:ok, topic} =
        Enum.find(existed_topics, %Topic{}, &(&1.name == topic_name))
        |> create_topic(%{name: topic_name, description: topic_desc})

      Enum.each(libraries, fn(map) ->
        %{ name: name, url: _, description: _ } = map

        {:ok, _} =
          Enum.find(existed_libs, %Library{}, &(&1.name == name))
          |> create_library(topic, map)
      end)
    end)
  end

  def create_library(%Library{} = library \\ %Library{}, %Topic{} = topic, attrs) do
    library
    |> Library.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:topic, topic)
    |> Repo.insert()
  end

  def create_topic(%Topic{} = topic \\ %Topic{}, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def list_topics do
    Repo.all(Topic)
  end

  def list_libraries do
    Repo.all(Library)
  end
end
