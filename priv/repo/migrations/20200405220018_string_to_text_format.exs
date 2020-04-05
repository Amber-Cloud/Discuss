defmodule Discuss.Repo.Migrations.StringToTextFormat do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      modify :body, :text
    end
    alter table(:comments) do
      modify :content, :text
    end
  end
end
