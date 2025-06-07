defmodule WhatsappClone.Repo.Migrations.AddUpdatedAtToConversations do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add :updated_at, :utc_datetime, null: false, default: fragment("now()")

    end
  end
end
