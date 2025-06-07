defmodule WhatsappClone.Repo.Migrations.CreateAttachments do
  use Ecto.Migration

  def change do
    create table(:attachments, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :message_id, references(:messages, type: :uuid, on_delete: :delete_all), null: false
      add :file_url, :text, null: false
      add :mime_type, :text, null: false
      add :file_size, :bigint
      add :inserted_at, :timestamptz, null: false, default: fragment("now()")
    end
  end
end
