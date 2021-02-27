defmodule Awatcher.Parser do
  def parse(data) do
    # crop non-related data
    [lib_data, _] = String.split(data, "# Resources")

    case parse_to_groups(lib_data) do
      [_|_] = list ->
        Enum.map(list, &(parse_groups/1))
      [] ->
        raise "Splitting by topics failed"
    end
  end

  def parse_groups(data) do
    [topic, raw_desc | raw_lib_list] = String.split(data, "\n")
    [topic_desc] = Regex.run(~r/(?<=\*).+?(?=\*)/, raw_desc)
    lib_list =
      Enum.filter(raw_lib_list, &(&1 != ""))
      |> Enum.map(&parse_line/1)
      |> Enum.reject(&is_nil/1)
    %{topic: topic, topic_desc: topic_desc, libraries: lib_list}
  end

  def parse_line(line) do
    case Regex.run(~r/\[(.+?)\]\((.+?)\)\s-\s(.+?)$/, line) do
      [_match, name, url, desc] ->
        %{ name: name, url: url, description: desc }
      _ -> nil
    end
  end

  def parse_to_groups(data) do
    Regex.scan(~r/(?<=##\s).+?(?=\n##)/s, data)
    |> List.flatten()
  end
end
