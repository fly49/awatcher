defmodule Awatcher.Records.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :description, :string
    field :name, :string
    has_many :libraries, Awatcher.Records.Library

    timestamps()
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> unique_constraint(:name)
  end
end
