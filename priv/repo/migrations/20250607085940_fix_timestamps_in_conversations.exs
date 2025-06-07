defmodule WhatsappClone.Repo.Migrations.FixTimestampsInConversations do
  use Ecto.Migration

  def change do
    # Alter inserted_at to timestamptz(6) with timezone and microseconds precision
    execute "ALTER TABLE conversations ALTER COLUMN inserted_at TYPE timestamptz(6) USING inserted_at::timestamptz(6)"

    # Alter updated_at to timestamptz(6) with timezone and microseconds precision
    execute "ALTER TABLE conversations ALTER COLUMN updated_at TYPE timestamptz(6) USING updated_at::timestamptz(6)"
  end
end
