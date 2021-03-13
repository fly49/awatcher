defmodule Awatcher.Repo.Migrations.AddTopicIdToLibrary do
  use Ecto.Migration

  def change do
    alter table(:libraries) do
      add :topic_id, references(:topics)
    end
  end
end
