defmodule Awatcher.Syncer do
  use GenServer
  alias Awatcher.{Downloader, Parser}

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

  # @url "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"
  # def handle_info(:sync, state) do
  #   @url
  #     |> Downloader.download()
  #     |> Parser.parse()
  #     |> Awatcher.Records.create_records()
  #   {:noreply, state}
  # end
end
