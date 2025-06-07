defmodule WhatsappClone.Repo.Migrations.AddHashedPasswordToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :hashed_password, :text  # Don't set null: false yet
    end
  end
end
