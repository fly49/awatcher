defmodule Awatcher.Records do
  import Ecto.Query, warn: false
  alias Awatcher.Repo
  alias Awatcher.Records.Library
  alias Awatcher.Records.Topic

  def create_library(%Topic{} = topic, attrs \\ %{}) do
    %Library{}
    |> Library.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:topic, topic)
    |> Repo.insert()
  end

  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end
end
