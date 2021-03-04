defmodule Awatcher.Records do
  import Ecto.Query, warn: false
  alias Awatcher.Repo
  alias Awatcher.Records.Library
  alias Awatcher.Records.Topic

  def create_library(%Topic{} = topic, attrs) do
    %Library{}
    |> Library.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:topic, topic)
    |> Ecto.Changeset.put_change(:present, attrs[:present] || true)
    |> Repo.insert()
  end

  def update_library(%Library{} = library, attrs) do
    library
    |> Library.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:topic, attrs[:topic])
    |> Ecto.Changeset.put_change(:present, attrs[:present] || true)
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

  def list_topics do
    Repo.all(Topic)
  end

  def list_libraries do
    Repo.all(Library) |> Repo.preload(:topic)
  end

  def get_topic_by(params) do
    Repo.get_by(Topic, params)
  end

  def get_library_by(params) do
    Repo.get_by(Library, params)
    |> Repo.preload(:topic)
  end
end
