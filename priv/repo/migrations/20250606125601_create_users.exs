defmodule WhatsappClone.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"")

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :username, :text, null: false
      add :phone_number, :text, null: false
      add :display_name, :text, null: false
      add :avatar_url, :text
      add :public_key, :text, null: false
      timestamps(type: :timestamptz)
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:phone_number])
  end
end
