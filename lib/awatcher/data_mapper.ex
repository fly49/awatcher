defmodule Awatcher.DataMapper do
  alias Awatcher.{HttpClient, Records, MdListParser}

  # File is downloaded from raw domain to not bother with base64 decoding
  @url "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"
  def prepare_data(ets_name) do
    fill_ets(ets_name)

    HttpClient.get(@url)
    |> MdListParser.parse()
    # list_topics() is used for topic create/update checking,
    # avoiding redundant SQL queries
    |> assign_topics()
  end

  def assign_topics(list_of_maps) do
    existing_topics = Records.list_topics()

    Enum.flat_map(list_of_maps, &(process_topic_group(&1, existing_topics)))
  end

  def process_topic_group(%{libraries: lib_list} = topic_attrs, existing_topics) do
    {:ok, %Records.Topic{id: topic_id}} = create_or_update_topic(topic_attrs, existing_topics)

    Enum.map(lib_list, fn lib -> Map.put(lib, :topic_id, topic_id) end)
  end

  def create_or_update_topic(%{topic: topic_name, topic_desc: topic_desc}, existing_topics) do
    case Enum.find(existing_topics, &(&1.name == topic_name)) do
      %Records.Topic{} = topic ->
        Records.update_topic(topic, %{description: topic_desc})
      nil ->
        Records.create_topic(%{name: topic_name, description: topic_desc})
    end
  end

  defp fill_ets(ets_name) do
    data = Records.list_libraries() |> Enum.map(fn lib -> {lib.name, lib} end)

    true = :ets.delete_all_objects(ets_name)
    true = :ets.insert(ets_name, data)
  end
end
