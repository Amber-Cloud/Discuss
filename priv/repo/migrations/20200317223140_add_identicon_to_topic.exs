defmodule Discuss.Repo.Migrations.AddIdenticonToTopic do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :identicon, :string
    end
  end
end
