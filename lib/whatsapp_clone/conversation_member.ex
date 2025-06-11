# defmodule WhatsappClone.ConversationMember do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "conversation_members" do
#     field :joined_at, :utc_datetime_usec
#     field :is_admin, :boolean, default: false
#     field :conversation_id, :binary_id
#     field :user_id, :binary_id

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(conversation_member, attrs) do
#     conversation_member
#     |> cast(attrs, [:joined_at, :is_admin])
#     |> validate_required([:joined_at, :is_admin])
#   end
# end
# defmodule WhatsappClone.ConversationMember do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "conversation_members" do
#     field :joined_at, :utc_datetime_usec
#     field :is_admin, :boolean, default: false
#     field :conversation_id, :binary_id
#     field :user_id, :binary_id

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(conversation_member, attrs) do
#     conversation_member
#     |> cast(attrs, [:joined_at, :is_admin, :conversation_id, :user_id])
#     |> validate_required([:joined_at, :is_admin, :conversation_id, :user_id])
#     |> unique_constraint(:user_id, name: :conversation_members_conversation_id_user_id_index)
#   end

# end


defmodule WhatsappClone.ConversationMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "conversation_members" do
    field :joined_at, :utc_datetime_usec
    field :is_admin, :boolean, default: false
    # field :conversation_id, :binary_id
    # field :user_id, :binary_id
    belongs_to :conversation, WhatsappClone.Conversation, type: :binary_id
    belongs_to :user, WhatsappClone.User, type: :binary_id


    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(conversation_member, attrs) do
    conversation_member
    |> cast(attrs, [:joined_at, :is_admin, :conversation_id, :user_id])
    |> validate_required([:joined_at, :is_admin, :conversation_id, :user_id])
    |> unique_constraint(:user_id, name: :conversation_members_conversation_id_user_id_index)
  end
end
