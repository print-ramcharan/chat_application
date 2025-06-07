defmodule WhatsappClone.Repo.Migrations.AddUpdatedAtToAttachments do
  use Ecto.Migration

  def change do
    alter table(:attachments) do
      add :updated_at, :timestamptz, null: false, default: fragment("now()")
    end
  end
end
