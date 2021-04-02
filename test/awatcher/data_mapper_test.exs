defmodule Awatcher.DataMapperTest do
  use Awatcher.DataCase, async: true
  alias Awatcher.DataMapper
  alias Awatcher.Records.Topic

  describe "create_or_update_topic/2" do
    test "creates new topic when no topic with provided name present" do
      topic = topic_fixture(%{name: "some name"})
      existing_topics = [topic]

      assert {:ok, %Topic{} = new_topic} = DataMapper.create_or_update_topic(%{topic: "another name", topic_desc: "desc"}, existing_topics)
      assert new_topic.id != topic.id
      assert new_topic.name == "another name"
      assert new_topic.description == "desc"
    end

    test "updates topic when topic with the same name present" do
      topic = topic_fixture(%{name: "some name", description: "desc"})
      topic_id = topic.id
      existing_topics = [topic]

      assert {:ok, %Topic{} = topic} = DataMapper.create_or_update_topic(%{topic: "some name", topic_desc: "another desc"}, existing_topics)
      assert topic.id == topic_id
      assert topic.name == "some name"
      assert topic.description == "another desc"
    end
  end
end
