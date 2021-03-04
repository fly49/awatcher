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
    alias Awatcher.Records.Library
    @valid_attrs %{name: "jason", url: "url", description: "A blazing fast JSON parser and generator in pure Elixir"}
    @invalid_attrs %{name: nil, url: nil, description: nil}

    test "list_libraries/0 returns all libraries with preloaded library" do
      topic = topic_fixture()
      %Library{id: id1} = library_fixture(topic)
      assert [%Library{id: ^id1}] = Records.list_libraries()

      %Library{id: id2} = library_fixture(topic)
      assert [%Library{id: ^id1}, %Library{id: ^id2}] = Records.list_libraries()
    end

    test "create_library/2 returns the library with given id" do
      topic = topic_fixture()
      assert {:ok, %Library{} = library} = Records.create_library(topic, @valid_attrs)

      assert library.name == @valid_attrs.name
      assert library.description == @valid_attrs.description
      assert library.topic == topic
    end

    test "create_library/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = Records.create_library(topic, @invalid_attrs)
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
      new_topic = topic_fixture()

      assert {:ok, %Library{} = library} = Records.update_library(library, %{topic: new_topic})
      assert library.topic == new_topic
    end

    test "update_library/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      library = library_fixture(topic)

      assert {:error, %Ecto.Changeset{}} = Records.update_library(library, @invalid_attrs)
    end
  end
end
