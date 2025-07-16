defmodule WhatsappClone.Repo.Migrations.AddReplyToIdToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :reply_to_id, references(:messages, type: :uuid, on_delete: :nilify_all)
    end

    create index(:messages, [:reply_to_id])
  end
end
