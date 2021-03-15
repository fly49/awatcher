defmodule Awatcher.SyncFunctions do
  alias Awatcher.Records
  alias Awatcher.Records.{Topic, Library}

  def assign_topics(list_of_maps, existing_topics) do
    Enum.flat_map(list_of_maps, fn map ->
      %{topic: name, topic_desc: description, libraries: lib_list} = map

      {:ok, %Topic{id: topic_id}} = process_topic(name, description, existing_topics)

      Enum.map(lib_list, fn lib -> Map.put(lib, :topic_id, topic_id) end)
    end)
  end

  def process_topic(topic_name, topic_desc, existing_topics) do
    case Enum.find(existing_topics, &(&1.name == topic_name)) do
      %Topic{} = topic ->
        Records.update_topic(topic, %{description: topic_desc})
      nil ->
        Records.create_topic(%{name: topic_name, description: topic_desc})
    end
  end

  def process_library(%{name: lib_name} = lib_attrs, ets_name) do
    case :ets.lookup(ets_name, lib_name) do
      [ {^lib_name, %Library{} = lib} ] ->
        Records.update_library(lib, lib_attrs)
      [] ->
        Records.create_library(lib_attrs)
      _ ->
        raise("ETS #{ets_name} has duplicates")
    end
  end
end
