defmodule Awatcher.RecordsTest do
  use Awatcher.DataCase, async: true
  alias Awatcher.Records

  describe "topics" do
    alias Awatcher.Records.Topic
    @valid_attrs %{name: "Actors", description: "Libraries and tools for working with actors and such."}
    @invalid_attrs %{name: nil, description: nil}

    test "list_topics/0 returns all topics" do
      %Topic{id: id1} = topic_fixture()
      assert [%Topic{id: ^id1}] = Records.list_topics()

      %Topic{id: id2} = topic_fixture()
      assert [%Topic{id: ^id1}, %Topic{id: ^id2}] = Records.list_topics()
    end

    test "create_topic/1 returns the topic with given id" do
      assert {:ok, %Topic{} = topic} = Records.create_topic(@valid_attrs)

      assert topic.name == @valid_attrs.name
      assert topic.description == @valid_attrs.description
    end

    test "create_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Records.create_topic(@invalid_attrs)
    end

    test "update_topic/2 with valid data updates the topic" do
      topic = topic_fixture()

      assert {:ok, %Topic{} = topic} = Records.update_topic(topic, %{description: "updated description"})
      assert topic.description == "updated description"
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()

      assert {:error, %Ecto.Changeset{}} = Records.update_topic(topic, @invalid_attrs)
    end
  end

  describe "libraries" do
    alias Awatcher.Records.{Library, Topic}
    @valid_attrs %{name: "jason", url: "url", description: "A blazing fast JSON parser and generator in pure Elixir"}
    @invalid_attrs %{name: nil, url: nil, description: nil}

    test "list_libraries/0 returns all libraries with preloaded library" do
      topic = topic_fixture()
      %Library{id: id1} = library_fixture(topic)
      assert [%Library{id: ^id1}] = Records.list_libraries()
    end

    test "create_library/1 with valid data and existing topic_id returns the library" do
      %Topic{id: topic_id} = topic_fixture()
      attrs = Map.put(@valid_attrs, :topic_id, topic_id)
      assert {:ok, %Library{} = library} = Records.create_library(attrs)

      assert library.name == @valid_attrs.name
      assert library.description == @valid_attrs.description
      assert library.topic_id == topic_id
    end

    test "create_library/1 with invalid data returns error changeset" do
      %Topic{id: topic_id} = topic_fixture()
      attrs = Map.put(@invalid_attrs, :topic_id, topic_id)
      assert {:error, %Ecto.Changeset{}} = Records.create_library(attrs)
    end

    test "create_library/1 with valid data but non-existing topic_id returns error changeset" do
      attrs = Map.put(@valid_attrs, :topic_id, 999)
      assert {:error, %Ecto.Changeset{}} = Records.create_library(attrs)
    end

    test "update_library/2 with valid data updates the topic" do
      topic = topic_fixture()
      library = library_fixture(topic)

      assert {:ok, %Library{} = library} = Records.update_library(library, %{url: "updated url"})
      assert library.url == "updated url"
    end

    test "update_library/2 with topic provided updates the association" do
      topic = topic_fixture()
      library = library_fixture(topic)
      %Topic{id: new_topic_id} = topic_fixture()

      assert {:ok, %Library{} = library} = Records.update_library(library, %{topic_id: new_topic_id})
      assert library.topic_id == new_topic_id
    end

    test "update_library/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      library = library_fixture(topic)

      assert {:error, %Ecto.Changeset{}} = Records.update_library(library, @invalid_attrs)
    end

    test "update_library/2 with valid data but non-existing topic_id returns error changeset" do
      topic = topic_fixture()
      library = library_fixture(topic)

      attrs = Map.put(@valid_attrs, :topic_id, 999)
      assert {:error, %Ecto.Changeset{}} = Records.update_library(library, attrs)
    end
  end
end
