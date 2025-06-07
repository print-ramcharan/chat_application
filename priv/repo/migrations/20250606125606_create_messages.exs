defmodule WhatsappClone.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def up do
    execute("CREATE TYPE message_type AS ENUM ('text', 'image', 'video', 'audio', 'file')")

    create table(:messages, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :conversation_id, references(:conversations, type: :uuid, on_delete: :delete_all), null: false
      add :sender_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :encrypted_body, :text, null: false
      add :message_type, :message_type, null: false, default: "text"
      add :media_url, :text
      add :inserted_at, :timestamptz, null: false, default: fragment("now()")
    end
  end

  def down do
    drop table(:messages)
    execute("DROP TYPE message_type")
  end
end
