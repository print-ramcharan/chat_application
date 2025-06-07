defmodule WhatsappClone.Repo.Migrations.AddTimestampsToMessageStatuses do
  use Ecto.Migration

  def change do
    alter table(:message_statuses) do
      timestamps()
    end
  end
end
