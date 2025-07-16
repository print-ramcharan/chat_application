# defmodule WhatsappClone.Attachment do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "attachments" do
#     field :file_url, :string
#     field :mime_type, :string
#     field :file_size, :integer
#     field :inserted_at, :utc_datetime_usec
#     field :message_id, :binary_id

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(attachment, attrs) do
#     attachment
#     |> cast(attrs, [:file_url, :mime_type, :file_size, :inserted_at])
#     |> validate_required([:file_url, :mime_type, :file_size, :inserted_at])
#   end
# end

# defmodule WhatsappClone.Attachment do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "attachments" do
#     field :file_url, :string
#     field :mime_type, :string
#     field :file_size, :integer

#     belongs_to :message, WhatsappClone.Message

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(attachment, attrs) do
#     attachment
#     |> cast(attrs, [:file_url, :mime_type, :file_size, :message_id])
#     |> validate_required([:file_url, :mime_type, :message_id])
#   end
# end


# defmodule WhatsappClone.Attachment do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   @derive {Jason.Encoder, only: [
#     :id, :file_url, :mime_type, :message_id, :inserted_at, :updated_at
#   ]}
#   schema "attachments" do
#     field :file_url, :string
#     field :mime_type, :string
#     field :message_id, :binary_id
#     field :file_size, :integer

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(attachment, attrs) do
#     attachment
#     |> cast(attrs, [:file_url, :mime_type, :message_id])
#     |> validate_required([:file_url, :mime_type, :message_id])
#   end
# end


defmodule WhatsappClone.Attachment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder, only: [
    :id, :file_data, :mime_type, :file_size, :message_id, :inserted_at, :updated_at
  ]}
  schema "attachments" do
    # Store the actual binary data of the file
    field :file_data, :binary

    # Store MIME type for the file (e.g., "image/jpeg", "audio/mp3")
    field :mime_type, :string

    # Store the size of the file
    field :file_size, :integer

    # Foreign key relation to the message the attachment belongs to
    belongs_to :message, WhatsappClone.Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [:file_data, :mime_type, :file_size, :message_id])
    |> validate_required([:file_data, :mime_type, :message_id])
  end
end
