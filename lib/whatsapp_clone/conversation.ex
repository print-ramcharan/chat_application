# defmodule WhatsappClone.Conversation do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "conversations" do
#     field :is_group, :boolean, default: false
#     field :group_name, :string
#     field :group_avatar_url, :string
#     field :inserted_at, :utc_datetime_usec
#     field :created_by, :binary_id

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(conversation, attrs) do
#     conversation
#     |> cast(attrs, [:is_group, :group_name, :group_avatar_url, :inserted_at])
#     |> validate_required([:is_group, :group_name, :group_avatar_url, :inserted_at])
#   end
# # end
# defmodule WhatsappClone.Conversation do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "conversations" do
#     field :is_group, :boolean, default: false
#     field :group_name, :string
#     field :group_avatar_url, :string
#     field :created_by, :binary_id

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(conversation, attrs) do
#     conversation
#     |> cast(attrs, [:is_group, :group_name, :group_avatar_url, :created_by])
#     |> validate_required([:is_group, :created_by])
#   end
# end
# defmodule WhatsappClone.Conversation do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "conversations" do
#     field :is_group, :boolean, default: false
#     field :group_name, :string
#     field :group_avatar_url, :string
#     field :created_by, :binary_id

#     has_many :conversation_members, WhatsappClone.ConversationMember, foreign_key: :conversation_id
#     has_many :messages, WhatsappClone.Message, foreign_key: :conversation_id

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(conversation, attrs) do
#     conversation
#     |> cast(attrs, [:is_group, :group_name, :group_avatar_url, :created_by])
#     |> validate_required([:is_group, :created_by])
#     |> validate_group_name()
#     |> assoc_constraint(:created_by)
#   end

#   defp validate_group_name(changeset) do
#     is_group = get_field(changeset, :is_group)
#     group_name = get_field(changeset, :group_name)

#     if is_group and is_nil(group_name) do
#       add_error(changeset, :group_name, "Group name is required for group conversations")
#     else
#       changeset
#     end
#   end
# end


# defmodule WhatsappClone.Conversation do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "conversations" do
#     field :is_group, :boolean, default: false
#     field :group_name, :string
#     field :group_avatar_url, :string
#     field :created_by, :binary_id

#     has_many :conversation_members, WhatsappClone.ConversationMember, foreign_key: :conversation_id
#     has_many :messages, WhatsappClone.Message, foreign_key: :conversation_id

#     timestamps(type: :utc_datetime_usec)

#   end

#   @doc false
#   def changeset(conversation, attrs) do
#     conversation
#     |> cast(attrs, [:is_group, :group_name, :group_avatar_url, :created_by])
#     |> validate_required([:is_group, :created_by])
#     |> validate_group_name()
#   end

#   defp validate_group_name(changeset) do
#     is_group = get_field(changeset, :is_group)
#     group_name = get_field(changeset, :group_name)

#     if is_group and is_nil(group_name) do
#       add_error(changeset, :group_name, "Group name is required for group conversations")
#     else
#       changeset
#     end
#   end
# end

defmodule WhatsappClone.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "conversations" do
    field :is_group, :boolean, default: false
    field :group_name, :string
    field :group_avatar_url, :string
    field :created_by, :binary_id

    has_many :conversation_members, WhatsappClone.ConversationMember, foreign_key: :conversation_id
    has_many :messages, WhatsappClone.Message, foreign_key: :conversation_id

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:is_group, :group_name, :group_avatar_url, :created_by])
    |> validate_required([:is_group, :created_by])
    |> validate_group_name()
  end

  defp validate_group_name(changeset) do
    is_group = get_field(changeset, :is_group)
    group_name = get_field(changeset, :group_name)

    if is_group and is_nil(group_name) do
      add_error(changeset, :group_name, "Group name is required for group conversations")
    else
      changeset
    end
  end
end
