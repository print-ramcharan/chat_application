defmodule WhatsappClone.Repo.Migrations.AddUpdatedAtToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :updated_at, :utc_datetime_usec
    end
  end
end
