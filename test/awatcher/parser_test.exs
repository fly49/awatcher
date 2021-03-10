defmodule Awatcher.ParserTest do
  use Awatcher.DataCase, async: true
  alias Awatcher.Parser

  test "parse_to_groups()" do
    data =
    """
    ## Actors
    *Libraries and tools for working with actors and such.*

    * [bpe](https://github.com/spawnproc/bpe) - Business Process Engine in Erlang.

    ## Algorithms and Data structures
    *Libraries and implementations of algorithms and data structures.*

    * [array](https://github.com/takscape/elixir-array) - An Elixir wrapper library for Erlang's array.

    ##
    """
    valid_data =
    [
    """
    Actors
    *Libraries and tools for working with actors and such.*

    * [bpe](https://github.com/spawnproc/bpe) - Business Process Engine in Erlang.
    """,
    """
    Algorithms and Data structures
    *Libraries and implementations of algorithms and data structures.*

    * [array](https://github.com/takscape/elixir-array) - An Elixir wrapper library for Erlang's array.
    """
    ]

    assert Parser.parse_to_groups(data) == valid_data
  end

  describe "parse_line()" do
    test "detect groups and parse them to map" do
      data = "* [bpe](https://github.com/spawnproc/bpe) - Business Process Engine in Erlang."
      valid_data = %{name: "bpe", url: "https://github.com/spawnproc/bpe", description: "Business Process Engine in Erlang."}

      assert Parser.parse_line(data) == valid_data
    end

    test "return nil if one of the groups can't be detected" do
      data = "* [bpe] - Business Process Engine in Erlang."
      assert Parser.parse_line(data) == nil
    end
  end

  test "parse_groups()" do
    data =
    """
    Audio and Sounds
    *Libraries working with sounds and tones.*

    * [erlaudio](https://github.com/asonge/erlaudio) - Erlang PortAudio bindings.
    * [firmata](https://github.com/entone/firmata) - This package implements the Firmata protocol.
    """
    valid_data =
      %{
        topic: "Audio and Sounds",
        topic_desc: "Libraries working with sounds and tones.",
        libraries: [
          %{name: "erlaudio", url: "https://github.com/asonge/erlaudio", description: "Erlang PortAudio bindings."},
          %{name: "firmata", url: "https://github.com/entone/firmata", description: "This package implements the Firmata protocol."}
        ]
      }

    assert Parser.parse_groups(data) == valid_data
  end
end
