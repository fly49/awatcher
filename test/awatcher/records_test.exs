defmodule Awatcher.RecordsTest do
  use Awatcher.DataCase, async: true
  alias Awatcher.Records
  alias Awatcher.Records.{Topic, Library}

  describe "create_topic()" do
    @valid_attrs %{name: "Actors", description: "Libraries and tools for working with actors and such."}

    test "with valid data inserts topic" do
      assert {:ok, %Topic{id: id}=topic} = Records.create_topic(@valid_attrs)
      assert topic.name == @valid_attrs.name
      assert topic.description == @valid_attrs.description
      assert [%Topic{id: ^id}] = Records.list_topics()
    end

    test "with provided topic updates one" do
      {:ok, old_topic} = Records.create_topic(@valid_attrs)

      assert {:ok, new_topic} = Records.create_topic(old_topic, %{name: "Actors", description: "Description"})
      assert new_topic.name == "Actors"
      assert new_topic.description == "Description"
      assert new_topic.id == old_topic.id
    end
  end

  describe "create_library()" do
    @valid_attrs %{name: "lib_name", url: "url", description: "desc"}

    test "with valid data inserts library" do
      {:ok, topic} = Records.create_topic(%{name: "Actors", description: "Description"})

      assert {:ok, %Library{id: id}=lib} = Records.create_library(topic, @valid_attrs)
      assert lib.name == @valid_attrs.name
      assert lib.description == @valid_attrs.description
      assert lib.topic == topic
      assert [%Library{id: ^id}] = Records.list_libraries()
    end

    test "with provided library updates one" do
      {:ok, topic} = Records.create_topic(%{name: "Actors", description: "Description"})
      {:ok, new_topic} = Records.create_topic(%{name: "XML", description: "xml"})
      {:ok, old_lib} = Records.create_library(topic, @valid_attrs)

      assert {:ok, %Library{id: id}=new_lib} = Records.create_library(old_lib, new_topic, %{name: "new_lib_name", url: "another_url", description: "another_desc"})
      assert new_lib.name == "new_lib_name"
      assert new_lib.url == "another_url"
      assert new_lib.description == "another_desc"
      assert new_lib.topic == new_topic
      assert [%Library{id: ^id}] = Records.list_libraries()
    end
  end
end
