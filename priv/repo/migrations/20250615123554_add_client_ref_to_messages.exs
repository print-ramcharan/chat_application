defmodule WhatsappClone.Repo.Migrations.AddClientRefToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :client_ref, :string
    end

    create unique_index(:messages, [:client_ref])
  end
end
