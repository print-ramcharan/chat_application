defmodule WhatsappClone.Repo.Migrations.AlterAvatarDataToBinary do
  use Ecto.Migration

  def up do
    execute("""
    ALTER TABLE users
    ALTER COLUMN avatar_data TYPE bytea
    USING decode(avatar_data, 'base64')
    """)
  end

  def down do
    execute("""
    ALTER TABLE users
    ALTER COLUMN avatar_data TYPE text
    USING encode(avatar_data, 'base64')
    """)
  end
end
