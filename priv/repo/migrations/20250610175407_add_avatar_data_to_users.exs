defmodule WhatsappClone.Repo.Migrations.AddAvatarDataToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :avatar_data, :text
    end
  end
end
