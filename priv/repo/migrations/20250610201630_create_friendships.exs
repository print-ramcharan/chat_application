defmodule WhatsappClone.Repo.Migrations.CreateFriendships do
  use Ecto.Migration

  def change do
    create table(:friendships, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :friend_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :status, :string, default: "pending", null: false

      timestamps()
    end

    create unique_index(:friendships, [:user_id, :friend_id])
  end
end
