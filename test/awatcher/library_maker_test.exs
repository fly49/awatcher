defmodule Awatcher.LibraryMakerTest do
  use Awatcher.DataCase, async: true
  alias Awatcher.SyncPipe.LibraryMaker
  alias Awatcher.Records.Library

  describe "create_or_update_library/3" do
    test "creates new library when no library with provided name present" do
      ets_name = :ets.new(:test, [:set, :public, :named_table])
      topic = topic_fixture()
      new_lib_attrs = %{name: "another name", url: "url", description: "desc", topic_id: topic.id}

      assert {:ok, %Library{} = new_library} = LibraryMaker.create_or_update_library(new_lib_attrs, ets_name)
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

      assert {:ok, %Library{} = upd_lib} = LibraryMaker.create_or_update_library(new_attrs, ets_name)
      assert upd_lib.id == library.id
      assert upd_lib.name == new_attrs.name
      assert upd_lib.url == new_attrs.url
      assert upd_lib.description == new_attrs.description
      assert upd_lib.topic_id == new_topic.id
    end
  end
end
