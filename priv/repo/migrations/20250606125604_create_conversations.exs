# defmodule WhatsappClone.Repo.Migrations.CreateConversations do
#   use Ecto.Migration

#   def change do
#     create table(:conversations, primary_key: false) do
#       add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
#       add :is_group, :boolean, null: false, default: false
#       add :group_name, :text
#       add :group_avatar_url, :text
#       add :created_by, references(:users, type: :uuid, on_delete: :restrict), null: false
#       add :inserted_at, :timestamptz, null: false, default: fragment("now()")
#     end
#   end
# end

defmodule WhatsappClone.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :is_group, :boolean, null: false, default: false
      add :group_name, :text
      add :group_avatar_url, :text
      add :created_by, references(:users, type: :uuid, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
