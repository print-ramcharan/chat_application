defmodule WhatsappClone.Repo.Migrations.AddUpdatedAtToConversations2 do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE conversations ALTER COLUMN updated_at TYPE timestamp(6) without time zone"
  end


end
