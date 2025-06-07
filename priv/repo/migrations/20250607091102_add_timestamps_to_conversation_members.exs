defmodule WhatsappClone.Repo.Migrations.AddTimestampsToConversationMembers do
  use Ecto.Migration

  def change do
    alter table(:conversation_members) do
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end
  end
end
