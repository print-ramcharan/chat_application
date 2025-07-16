defmodule WhatsappClone.Repo.Migrations.MakeEncryptedBodyNullableInMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      modify :encrypted_body, :text, null: true
    end
  end
end
