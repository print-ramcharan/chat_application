defmodule WhatsappClone.Repo.Migrations.CreateConversationMembers do
  use Ecto.Migration

  def change do
    create table(:conversation_members, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :conversation_id, references(:conversations, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :joined_at, :timestamptz, null: false, default: fragment("now()")
      add :is_admin, :boolean, null: false, default: false
    end

    create unique_index(:conversation_members, [:conversation_id, :user_id])
  end
end
