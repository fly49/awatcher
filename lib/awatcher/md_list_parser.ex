defmodule Awatcher.MdListParser do
  require Logger

  def parse(data) do
    data
    |> drop_non_related_data()
    |> split_by_topics()
    |> Enum.map(&parse_topic_group/1)
  end

  def drop_non_related_data(data) do
    [lib_data, _] = String.split(data, "# Resources")
    lib_data
  end

  def split_by_topics(data) do
    Regex.scan(~r/(?<=##\s).+?(?=\n##)/s, data)
    |> List.flatten()
    |> case do
      [_|_] = list ->
        list
      [] ->
        raise "Splitting by topics failed"
    end
  end

  def parse_topic_group(data) do
    [topic, raw_desc | raw_lib_list] = String.split(data, "\n")

    [topic_desc] = Regex.run(~r/(?<=\*).+?(?=\*)/, raw_desc)

    lib_list = parse_lib_list(raw_lib_list)

    %{topic: topic, topic_desc: topic_desc, libraries: lib_list}
  end

  def parse_lib_list(raw_lib_list) do
    raw_lib_list
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&parse_line/1)
    |> Enum.reject(&is_nil/1)
  end

  def parse_line(line) do
    case Regex.run(~r/\[(.+?)\]\((.+?)\)\s-\s(.+?)$/, line) do
      [_match, name, url, desc] ->
        %{ name: name, url: url, description: desc }
      _ ->
        nil
    end
  end
end
