defmodule Awatcher.SyncFunctionsTest do
  use Awatcher.DataCase, async: true
  alias Awatcher.SyncFunctions
  alias Awatcher.Records.{Topic, Library}

  describe "process_topic/3" do
    test "creates new topic when no topic with provided name present" do
      topic = topic_fixture(%{name: "some name"})
      existing_topics = [topic]

      assert {:ok, %Topic{} = new_topic} = SyncFunctions.process_topic("another name", "desc", existing_topics)
      assert new_topic.id != topic.id
      assert new_topic.name == "another name"
      assert new_topic.description == "desc"
    end

    test "updates topic when topic with the same name present" do
      topic = topic_fixture(%{name: "some name", description: "desc"})
      topic_id = topic.id
      existing_topics = [topic]

      assert {:ok, %Topic{} = topic} = SyncFunctions.process_topic("some name", "another desc", existing_topics)
      assert topic.id == topic_id
      assert topic.name == "some name"
      assert topic.description == "another desc"
    end
  end

  describe "process_library/3" do
    test "creates new library when no library with provided name present" do
      ets_name = :ets.new(:test, [:set, :public, :named_table])
      topic = topic_fixture()
      new_lib_attrs = %{name: "another name", url: "url", description: "desc", topic_id: topic.id}

      assert {:ok, %Library{} = new_library} = SyncFunctions.process_library(new_lib_attrs, ets_name)
      assert new_library.name == new_lib_attrs.name
      assert new_library.url == new_lib_attrs.url
      assert new_library.description == new_lib_attrs.description
    end

    test "updates library when library with the same name present" do
      topic = topic_fixture()
      library = library_fixture(topic, %{name: "name"})
      ets_name = :ets.new(:test, [:set, :public, :named_table])
      :ets.insert(:test, {library.name, library})

      new_topic = topic_fixture()
      new_attrs = %{name: "name", url: "new url", description: "new description", topic_id: new_topic.id}

      assert {:ok, %Library{} = upd_lib} = SyncFunctions.process_library(new_attrs, ets_name)
      assert upd_lib.id == library.id
      assert upd_lib.name == new_attrs.name
      assert upd_lib.url == new_attrs.url
      assert upd_lib.description == new_attrs.description
      assert upd_lib.topic_id == new_topic.id
    end
  end
end
