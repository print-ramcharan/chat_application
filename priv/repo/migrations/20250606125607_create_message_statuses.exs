defmodule WhatsappClone.Repo.Migrations.CreateMessageStatuses do
  use Ecto.Migration

  def up do
    execute("CREATE TYPE status_enum AS ENUM ('sent', 'delivered', 'read', 'pending')")

    create table(:message_statuses, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :message_id, references(:messages, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :status, :status_enum, null: false, default: "sent"
      add :status_ts, :timestamptz, null: false, default: fragment("now()")
    end

    create unique_index(:message_statuses, [:message_id, :user_id])
  end

  def down do
    drop table(:message_statuses)
    execute("DROP TYPE status_enum")
  end
end
