defmodule WhatsappClone.Repo.Migrations.CreateFriendRequests do
  use Ecto.Migration

  def change do
    create table(:friend_requests, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :from_user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :to_user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :status, :string, null: false, default: "pending" # "pending", "accepted", "declined"
      timestamps()
    end

    create unique_index(:friend_requests, [:from_user_id, :to_user_id])
  end

end
