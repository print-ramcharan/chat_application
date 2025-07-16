defmodule WhatsappClone.Repo.Migrations.AddMediaToMessageType do
  use Ecto.Migration

  def up do
    execute("""
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_enum e ON t.oid = e.enumtypid
        WHERE t.typname = 'message_type' AND e.enumlabel = 'media'
      ) THEN
        ALTER TYPE message_type ADD VALUE 'media';
      END IF;
    END$$;
    """)
  end

  def down do
    # Enum values cannot be removed in PostgreSQL
    IO.puts("Cannot remove 'media' value from message_type enum")
  end
end
