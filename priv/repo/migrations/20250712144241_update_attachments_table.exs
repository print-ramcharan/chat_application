defmodule WhatsappClone.Repo.Migrations.UpdateAttachmentsTable do
  use Ecto.Migration

  def change do
    alter table(:attachments) do
      # Remove the file_url column, since we are not storing URLs anymore
      remove :file_url

      # Add the file_data column to store the actual binary data of the file
      add :file_data, :binary
    end
  end
end
