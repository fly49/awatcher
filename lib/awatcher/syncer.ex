defmodule Awatcher.Syncer do
  use GenServer
  alias Awatcher.{Downloader, Parser, Records}
  alias Awatcher.Records.{Topic, Library}

  def start_link(interval) do
    GenServer.start_link(__MODULE__, interval, name: __MODULE__)
  end

  def init(interval) do
    schedule_sync(interval)
    {:ok, interval}
  end

  defp schedule_sync(interval) do
    Process.send_after(self(), :sync, interval)
  end

  @url "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"
  def handle_info(:sync, state) do
    {:ok, :processed} =
      @url
      |> Downloader.download()
      |> Parser.parse()
      |> process_parsed_data()

    {:noreply, state}
  end

  def process_parsed_data(list_of_maps) do
    existing_topics = Records.list_topics()
    existing_libs = Records.list_libraries()

    created_libs = create_libraries_with_topics(list_of_maps, existing_topics, existing_libs)
    {:ok, :marked} = mark_outdated_libraries(created_libs, existing_libs)

    {:ok, :processed}
  end

  def create_libraries_with_topics(list_of_maps, existing_topics, existing_libs) do
    libs =
      Enum.reduce(list_of_maps, [], fn(map, acc) ->
        %{topic: topic_name, topic_desc: topic_desc, libraries: libraries} = map

        {:ok, topic} = process_topic(topic_name, topic_desc, existing_topics)
        new_libs =
          Enum.reduce(libraries, [], fn(map, acc) ->
            {:ok, lib} = process_library(map, topic, existing_libs)
            [lib | acc]
          end)

        [new_libs | acc]
      end)
    List.flatten(libs)
  end

  def process_topic(topic_name, topic_desc, existing_topics) do
    case Enum.find(existing_topics, &(&1.name == topic_name)) do
      %Topic{} = topic ->
        Records.update_topic(topic, %{description: topic_desc})
      nil ->
        Records.create_topic(%{name: topic_name, description: topic_desc})
    end
  end

  def process_library(%{name: lib_name} = lib_attrs, %Topic{} = lib_topic, existing_libs) do
    case Enum.find(existing_libs, &(&1.name == lib_name)) do
      %Library{} = lib ->
        Records.update_library(lib, Map.put(lib_attrs, :topic, lib_topic))
      nil ->
        Records.create_library(lib_topic, lib_attrs)
    end
  end

  def mark_outdated_libraries(created_libs, existing_libs) do
    id_mapset = MapSet.new(created_libs, &(&1.id))

    existing_libs
    |> Enum.reject(&(MapSet.member?(id_mapset, &1.id)))
    |> Enum.each(fn lib ->
      {:ok, _} = Records.update_library(lib, %{present: false})
    end)

    {:ok, :marked}
  end
end
