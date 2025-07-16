# defmodule WhatsappClone.Message do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "messages" do
#     field :encrypted_body, :string
#     field :media_url, :string
#     field :inserted_at, :utc_datetime_usec
#     field :conversation_id, :binary_id
#     field :sender_id, :binary_id

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(message, attrs) do
#     message
#     |> cast(attrs, [:encrypted_body, :media_url, :inserted_at])
#     |> validate_required([:encrypted_body, :media_url, :inserted_at])
#   end
# end
# defmodule WhatsappClone.Message do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "messages" do
#     field :encrypted_body, :string
#     field :media_url, :string

#     field :message_type, Ecto.Enum, values: [:text, :image, :video, :audio, :file], default: :text

#     belongs_to :conversation, WhatsappClone.Conversation
#     belongs_to :sender, WhatsappClone.User, foreign_key: :sender_id

#     timestamps(type: :utc_datetime_usec)
#   end

#   @doc false
#   def changeset(message, attrs) do
#     message
#     |> cast(attrs, [:encrypted_body, :media_url, :message_type, :conversation_id, :sender_id])
#     |> validate_required([:encrypted_body, :message_type, :conversation_id, :sender_id])
#   end
# end

# defmodule WhatsappClone.Message do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   schema "messages" do
#     field :encrypted_body, :string
#     field :message_type, Ecto.Enum, values: [:text, :image, :video, :audio, :file], default: :text
#     field :media_url, :string
#     belongs_to :conversation, WhatsappClone.Conversation, type: :binary_id
#     belongs_to :sender, WhatsappClone.User, type: :binary_id

#     timestamps(type: :utc_datetime_usec)
#   end

#   def changeset(message, attrs) do
#     message
#     |> cast(attrs, [:conversation_id, :sender_id, :encrypted_body, :message_type, :media_url])
#     |> validate_required([:conversation_id, :sender_id, :encrypted_body, :message_type])
#     |> foreign_key_constraint(:conversation_id)
#     |> foreign_key_constraint(:sender_id)
#   end
# end


# defmodule WhatsappClone.Message do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "messages" do
#     field :encrypted_body, :string
#     field :message_type, :string
#     field :sender_id, :binary_id
#     field :conversation_id, :binary_id

#     has_many :attachments, WhatsappClone.Attachment, foreign_key: :message_id
#     has_many :status_entries, WhatsappClone.MessageStatus, foreign_key: :message_id

#     timestamps(type: :utc_datetime)
#   end

#   @derive {Jason.Encoder, only: [
#     :id, :encrypted_body, :message_type, :sender_id, :conversation_id,
#     :inserted_at, :updated_at, :attachments, :status_entries
#   ]}
#   schema "messages" do
#     field :encrypted_body, :string
#     field :message_type, :string
#     belongs_to :sender, WhatsappClone.User, foreign_key: :sender_id
#     belongs_to :conversation, WhatsappClone.Conversation

#     has_many :attachments, WhatsappClone.Attachment
#     has_many :status_entries, WhatsappClone.MessageStatus, foreign_key: :message_id

#     timestamps()
#   end

#   @doc false
#   def changeset(message, attrs) do
#     message
#     |> cast(attrs, [:encrypted_body, :message_type, :sender_id, :conversation_id])
#     |> validate_required([:encrypted_body, :message_type, :sender_id, :conversation_id])
#   end
# end

# defmodule WhatsappClone.Message do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   @derive {Jason.Encoder, only: [
#     :id, :encrypted_body, :message_type, :sender_id, :conversation_id,
#     :inserted_at, :updated_at, :attachments, :status_entries
#   ]}
#   schema "messages" do
#     field :encrypted_body, :string
#     field :message_type, :string
#     field :client_ref, :string

#     belongs_to :sender, WhatsappClone.User, foreign_key: :sender_id
#     belongs_to :conversation, WhatsappClone.Conversation

#     has_many :attachments, WhatsappClone.Attachment, foreign_key: :message_id
#     has_many :status_entries, WhatsappClone.MessageStatus, foreign_key: :message_id

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(message, attrs) do
#     message
#     |> cast(attrs, [:encrypted_body, :message_type, :sender_id, :conversation_id, :client_ref])
#     |> validate_required([:message_type, :sender_id, :conversation_id])
#     |> validate_encrypted_body_if_needed(attrs)
#     |> unique_constraint(:client_ref)
#   end

#   defp validate_encrypted_body_if_needed(changeset, attrs) do
#     encrypted_body = get_field(changeset, :encrypted_body)

#     has_attachment? =
#       Map.has_key?(attrs, "attachment") or Map.has_key?(attrs, :attachment)

#     if is_nil(encrypted_body) or encrypted_body == "" do
#       if has_attachment? do
#         changeset
#       else
#         add_error(changeset, :encrypted_body, "can't be blank")
#       end
#     else
#       changeset
#     end
#   end
# end

defmodule WhatsappClone.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder, only: [
    :id, :encrypted_body, :message_type, :sender_id, :conversation_id,
    :reply_to_id, :inserted_at, :updated_at, :attachments, :status_entries
  ]}
  schema "messages" do
    field :encrypted_body, :string
    field :message_type, :string
    field :client_ref, :string

    belongs_to :sender, WhatsappClone.User, foreign_key: :sender_id
    belongs_to :conversation, WhatsappClone.Conversation

    belongs_to :reply_to, __MODULE__, foreign_key: :reply_to_id
    has_many :replies, __MODULE__, foreign_key: :reply_to_id


    has_many :attachments, WhatsappClone.Attachment, foreign_key: :message_id
    has_many :status_entries, WhatsappClone.MessageStatus, foreign_key: :message_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:encrypted_body, :message_type, :sender_id, :conversation_id, :client_ref, :reply_to_id])
    |> validate_required([:message_type, :sender_id, :conversation_id])
    |> maybe_validate_encrypted_body()
    |> unique_constraint(:client_ref)
    |> foreign_key_constraint(:reply_to_id)
  end

  defp maybe_validate_encrypted_body(changeset) do
    message_type = get_field(changeset, :message_type)
    encrypted_body = get_field(changeset, :encrypted_body)

    # Only validate encrypted_body if type is "text" or "reply"
    if message_type in ["text", "reply"] and is_nil_or_blank(encrypted_body) do
      add_error(changeset, :encrypted_body, "can't be blank")
    else
      changeset
    end
  end

  defp is_nil_or_blank(nil), do: true
  defp is_nil_or_blank(""), do: true
  defp is_nil_or_blank(_), do: false
end
