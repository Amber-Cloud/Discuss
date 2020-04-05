defmodule DiscussWeb.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:content, :user, :inserted_at]}

  schema "comments" do
    field :content, :string
    belongs_to :user, DiscussWeb.User
    belongs_to :topic, DiscussWeb.Topic

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content])
    |> validate_required([:content])
    |> validate_length(:content, min: 5, max: 1000)
  end
end