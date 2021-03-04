defmodule Awatcher.SyncTest do
  use Awatcher.DataCase, async: true
  alias Awatcher.{Syncer, Records}
  alias Awatcher.Records.{Topic, Library}

  describe "process_topic/3" do
    test "creates new topic when no topic with provided name present" do
      topic = topic_fixture(%{name: "some name"})
      existing_topics = [topic]

      assert {:ok, %Topic{} = new_topic} = Syncer.process_topic("another name", "desc", existing_topics)
      assert new_topic.id != topic.id
      assert new_topic.name == "another name"
      assert new_topic.description == "desc"
    end

    test "updates topic when topic with the same name present" do
      topic = topic_fixture(%{name: "some name", description: "desc"})
      topic_id = topic.id
      existing_topics = [topic]

      assert {:ok, %Topic{} = topic} = Syncer.process_topic("some name", "another desc", existing_topics)
      assert topic.id == topic_id
      assert topic.name == "some name"
      assert topic.description == "another desc"
    end
  end

  describe "process_library/3" do
    test "creates new library when no library with provided name present" do
      topic = topic_fixture()
      library = library_fixture(topic, %{name: "some name"})
      existing_libs = [library]
      another_topic = topic_fixture()
      new_lib_attrs = %{name: "another name", url: "url", description: "desc"}

      assert {:ok, %Library{} = new_library} = Syncer.process_library(new_lib_attrs, another_topic, existing_libs)
      assert new_library.id != library.id
      assert new_library.name == new_lib_attrs.name
      assert new_library.url == new_lib_attrs.url
      assert new_library.description == new_lib_attrs.description
    end

    test "updates library when library with the same name present" do
      topic = topic_fixture()
      library = library_fixture(topic, %{name: "some name"})
      library_id = library.id
      existing_libraries = [library]
      new_topic = topic_fixture()
      new_attrs = %{name: "some name", url: "new url", description: "new description"}

      assert {:ok, %Library{} = library} = Syncer.process_library(new_attrs, new_topic, existing_libraries)
      assert library.id == library_id
      assert library.name == new_attrs.name
      assert library.url == new_attrs.url
      assert library.description == new_attrs.description
    end
  end

  describe "create_libraries_with_topics/3" do
    test "returns list of created AND updated libraries with associated topics" do
      lib_11 = %{
        description: "An Elixir wrapper for the `redbug` production-friendly Erlang tracing debugger.",
        name: "rexbug",
        url: "https://github.com/nietaki/rexbug"
      }
      lib_12 = %{
        description: "A process visualizer for remote BEAM nodes.",
        name: "visualixir",
        url: "https://github.com/koudelka/visualixir"
      }
      map_1 = %{
        topic: "Debugging",
        topic_desc: "Libraries and tools for debugging code and applications.",
        libraries: [lib_11, lib_12]
      }
      lib_21 = %{
        description: "A fully-featured PaaS designed for Elixir. Supports clustering, hot upgrades, and remote console/observer. Free to try without a credit card.",
        name: "Gigalixir",
        url: "https://www.gigalixir.com"
      }
      lib_22 = %{
        description: "Heroku buildpack to deploy Elixir apps to Heroku.",
        name: "heroku-buildpack-elixir",
        url: "https://github.com/HashNuke/heroku-buildpack-elixir"
      }
      map_2 = %{
        topic: "Deployment",
        topic_desc: "Installing and running your code automatically on other machines.",
        libraries: [lib_21, lib_22]
      }
      topic = topic_fixture(%{name: map_1.topic, description: "blabla"})
      library = library_fixture(topic, %{name: lib_11.name, description: "murmur"})

      new_libs = Syncer.create_libraries_with_topics([map_1, map_2], [topic], [library])
      assert length(new_libs) == 4

      res_lib_11 = Records.get_library_by(name: lib_11.name)
      assert Enum.find(new_libs, fn lib ->
        (lib.id == res_lib_11.id) &&
        (lib.name == res_lib_11.name) &&
        (lib.url == res_lib_11.url) &&
        (lib.topic.id == res_lib_11.topic.id) &&
        (lib.topic.name == res_lib_11.topic.name)
      end)

      res_lib_12 = Records.get_library_by(name: lib_12.name)
      assert has_such_lib?(new_libs, res_lib_12)

      res_lib_21 = Records.get_library_by(name: lib_21.name)
      assert has_such_lib?(new_libs, res_lib_21)

      res_lib_22 = Records.get_library_by(name: lib_22.name)
      assert has_such_lib?(new_libs, res_lib_22)
    end
  end

  defp has_such_lib?(libs, lib) do
    Enum.find(libs, fn ex_lib ->
      ex_lib == lib
    end)
  end
end
