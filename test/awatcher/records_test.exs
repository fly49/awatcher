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

  describe "create_records()" do
    test "with valid data creates records" do
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

      assert {:ok, :created} = Records.create_records([map_1, map_2])

      res_lib_11 = Records.get_library_by(name: lib_11.name)
      assert lib_11.name == res_lib_11.name
      assert lib_11.url == res_lib_11.url
      assert lib_11.description == res_lib_11.description
      assert map_1.topic == res_lib_11.topic.name
      assert map_1.topic_desc == res_lib_11.topic.description

      res_lib_12 = Records.get_library_by(name: lib_12.name)
      assert lib_12.name == res_lib_12.name
      assert lib_12.url == res_lib_12.url
      assert lib_12.description == res_lib_12.description
      assert map_1.topic == res_lib_12.topic.name
      assert map_1.topic_desc == res_lib_12.topic.description

      res_lib_21 = Records.get_library_by(name: lib_21.name)
      assert lib_21.name == res_lib_21.name
      assert lib_21.url == res_lib_21.url
      assert lib_21.description == res_lib_21.description
      assert map_2.topic == res_lib_21.topic.name
      assert map_2.topic_desc == res_lib_21.topic.description

      res_lib_22 = Records.get_library_by(name: lib_22.name)
      assert lib_22.name == res_lib_22.name
      assert lib_22.url == res_lib_22.url
      assert lib_22.description == res_lib_22.description
      assert map_2.topic == res_lib_22.topic.name
      assert map_2.topic_desc == res_lib_22.topic.description
    end
  end
end
