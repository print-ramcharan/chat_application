defmodule WhatsappClone.Repo.Migrations.ChangeGroupAvatarUrlToBinary do
  use Ecto.Migration

  def up do
    # 1. Add a temporary binary column
    alter table(:conversations) do
      add :group_avatar_binary, :bytea
    end

    # 2. Optionally: If existing values are not valid base64, just skip this step.
    # This sets all binary fields to NULL instead of decoding
    execute """
    UPDATE conversations
    SET group_avatar_binary = NULL;
    """

    # 3. Remove the original text column
    alter table(:conversations) do
      remove :group_avatar_url
    end

    # 4. Rename binary column to original name
    rename table(:conversations), :group_avatar_binary, to: :group_avatar_url
  end

  def down do
    # Rollback: restore `text` column
    alter table(:conversations) do
      add :group_avatar_text, :text
    end

    execute """
    UPDATE conversations
    SET group_avatar_text = NULL;
    """

    alter table(:conversations) do
      remove :group_avatar_url
    end

    rename table(:conversations), :group_avatar_text, to: :group_avatar_url
  end
end
