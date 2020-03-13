defmodule Discuss.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      #tying the records to certain users
      add :email, :string
      add :provider, :string
      add :token, :string #would be useful if we wanted to interact with github

      timestamps() #user has last modified properties on every record of the table. record keeping
    end
  end
end
