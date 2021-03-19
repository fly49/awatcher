ExUnit.start(trace: true)
Ecto.Adapters.SQL.Sandbox.mode(Awatcher.Repo, :manual)

defmodule Awatcher.TestHelpers do
  alias Awatcher.Records

  def topic_fixture(attrs \\ %{}) do
    {:ok, topic} =
      attrs
      |> Enum.into(%{
        name: attrs[:name] || "sometopic#{System.unique_integer([:positive])}",
        description: attrs[:description] || "description"
      })
      |> Records.create_topic()

    topic
  end

  def library_fixture(%Records.Topic{id: topic_id}, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: attrs[:name] || "somelibrary#{System.unique_integer([:positive])}",
        url: attrs[:url] || "http://example.com",
        description: attrs[:description] || "a description",
        topic_id: topic_id
      })

    {:ok, library} = Records.create_library(attrs)
    library
  end
end

Mox.defmock(Awatcher.GithubMock, for: Awatcher.GithubClient)
