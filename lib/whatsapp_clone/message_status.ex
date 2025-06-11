# # defmodule WhatsappClone.MessageStatus do
# #   use Ecto.Schema
# #   import Ecto.Changeset

# #   @primary_key {:id, :binary_id, autogenerate: true}
# #   @foreign_key_type :binary_id
# #   schema "message_statuses" do
# #     field :status, :string
# #     field :status_ts, :utc_datetime_usec
# #     field :message_id, :binary_id
# #     field :user_id, :binary_id

# #     timestamps(type: :utc_datetime)
# #   end

# #   @doc false
# #   def changeset(message_status, attrs) do
# #     message_status
# #     |> cast(attrs, [:status, :status_ts])
# #     |> validate_required([:status, :status_ts])
# #   end
# # end

# defmodule WhatsappClone.MessageStatus do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "message_statuses" do
#     field :status, :string
#     field :status_ts, :utc_datetime_usec

#     belongs_to :message, WhatsappClone.Message
#     belongs_to :user, WhatsappClone.User

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(message_status, attrs) do
#     message_status
#     |> cast(attrs, [:status, :status_ts, :message_id, :user_id])
#     |> validate_required([:status, :status_ts, :message_id, :user_id])
#   end
# end

# defmodule WhatsappClone.MessageStatus do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   schema "message_statuses" do
#     field :status, Ecto.Enum, values: [:sent, :delivered, :read], default: :sent
#     field :status_ts, :utc_datetime_usec

#     belongs_to :message, WhatsappClone.Message, type: :binary_id
#     belongs_to :user, WhatsappClone.User, type: :binary_id

#     timestamps(type: :utc_datetime_usec)
#   end

#   def changeset(message_status, attrs) do
#     message_status
#     |> cast(attrs, [:message_id, :user_id, :status, :status_ts])
#     |> validate_required([:message_id, :user_id, :status])
#     |> foreign_key_constraint(:message_id)
#     |> foreign_key_constraint(:user_id)
#     |> unique_constraint(:message_user_unique, name: :message_statuses_message_id_user_id_index)
#   end
# end

# defmodule WhatsappClone.MessageStatus do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "message_statuses" do
#     field :message_id, :binary_id
#     field :user_id, :binary_id
#     field :status, :string
#     field :status_ts, :utc_datetime_usec

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(status_entry, attrs) do
#     status_entry
#     |> cast(attrs, [:message_id, :user_id, :status])
#     |> validate_required([:message_id, :user_id, :status])
#   end
# end

defmodule WhatsappClone.MessageStatus do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder, only: [
    :id, :message_id, :user_id, :status, :status_ts, :inserted_at, :updated_at
  ]}
  schema "message_statuses" do
    field :message_id, :binary_id
    field :user_id, :binary_id
    field :status, :string
    field :status_ts, :utc_datetime_usec

    timestamps(type: :naive_datetime)

  end

  @doc false
  def changeset(status_entry, attrs) do
    status_entry
    |> cast(attrs, [:message_id, :user_id, :status, :status_ts])
    |> validate_required([:message_id, :user_id, :status, :status_ts])
  end
end
