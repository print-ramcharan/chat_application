defmodule WhatsappClone.Repo.Migrations.AddFcmTokenToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :fcm_token, :text
    end
  end
end
