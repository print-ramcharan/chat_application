defmodule WhatsappClone.Repo.Migrations.AddLastReadAtToConversationMembers do
  use Ecto.Migration

  def change do
    alter table(:conversation_members) do
      add :last_read_at, :utc_datetime_usec
    end
  end

end
