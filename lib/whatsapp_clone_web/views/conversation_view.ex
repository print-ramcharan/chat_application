# defmodule WhatsappCloneWeb.ConversationView do
#   use WhatsappCloneWeb, :view
#   alias Postgrex.Binary

#   def render("index.json", %{conversations: conversations}) do
#     %{data: render_many(conversations, __MODULE__, "conversation.json")}
#   end

#   def render("show.json", %{conversation: conversation}) do
#     %{data: render_one(conversation, __MODULE__, "conversation.json")}
#   end

#   def render("message.json", %{message: msg}) do
#     %{
#       id: msg.id,
#       sender_id: msg.sender_id,
#       conversation_id: msg.conversation_id,
#       encrypted_body: msg.encrypted_body,
#       message_type: msg.message_type,
#       inserted_at: msg.inserted_at
#     }
#   end

#   def render("conversation.json", %{conversation: convo}) do
#     last_message =
#       case Map.get(convo, :last_message) do
#         nil -> nil
#         message -> render_one(message, __MODULE__, "message.json", as: :message)
#       end

#       %{
#         id: convo.id,
#         is_group: convo.is_group,
#         group_name: convo.group_name,
#         group_avatar_url: safe_encode_avatar(convo.group_avatar_url),
#         created_by: convo.creator,
#         inserted_at: convo.inserted_at,
#         updated_at: convo.updated_at,
#         last_message: last_message,
#         members: render_many(convo.conversation_members, WhatsappCloneWeb.UserView, "member.json")
#       }



#   end

#   defp safe_encode_avatar(nil), do: nil

# defp safe_encode_avatar(%Postgrex.Binary{bytes: bytes}) when is_binary(bytes) do
#   "data:image/png;base64," <> Base.encode64(bytes)
# end

# defp safe_encode_avatar(binary) when is_binary(binary) do
#   if String.printable?(binary) do
#     binary  # assume it's already a URL or safe string
#   else
#     "data:image/png;base64," <> Base.encode64(binary)
#   end
# end

# defp safe_encode_avatar(_), do: nil

#   def render("message.json", %{message: nil}), do: nil

#   def render("message.json", %{message: message}) do
#     %{
#       id: message.id,
#       sender_id: message.sender_id,
#       encrypted_body: message.encrypted_body,
#       message_type: message.message_type,
#       inserted_at: message.inserted_at
#     }
#   end

#   defp render_last_message(%{messages: %Ecto.Association.NotLoaded{}}), do: nil
#   defp render_last_message(%{messages: []}), do: nil

#   defp render_last_message(%{messages: messages}) when is_list(messages) do
#     case List.first(messages) do
#       nil -> nil
#       message -> extract_message_fields(message)
#     end
#   end

#   defp render_last_message(%WhatsappClone.Conversation{messages: messages}) do
#     render_last_message(%{messages: messages})
#   end

#   defp extract_message_fields(message) when is_map(message) do
#     %{
#       id: safe_get(message, :id) || safe_get(message, "id"),
#       sender_id: safe_get(message, :sender_id) || safe_get(message, "sender_id"),
#       encrypted_body: safe_get(message, :encrypted_body) || safe_get(message, "encrypted_body"),
#       message_type: safe_get(message, :message_type) || safe_get(message, "message_type"),
#       inserted_at: safe_get(message, :inserted_at) || safe_get(message, "inserted_at")
#     }
#   end

#   defp extract_message_fields(_), do: nil

#   defp safe_get(map, key) when is_atom(key) do
#     Map.get(map, key) || Map.get(map, to_string(key))
#   end

#   defp safe_get(map, key) when is_binary(key) do
#     Map.get(map, key) || Map.get(map, String.to_existing_atom(key))
#   rescue
#     ArgumentError -> nil
#   end
# end

defmodule WhatsappCloneWeb.ConversationView do
  use WhatsappCloneWeb, :view

  def render("index.json", %{conversations: conversations}) do
    %{data: render_many(conversations, __MODULE__, "conversation.json")}
  end

  def render("show.json", %{conversation: conversation}) do
    %{data: render_one(conversation, __MODULE__, "conversation.json")}
  end

  def render("conversation.json", %{conversation: convo}) do
    last_message =
      case Map.get(convo, :last_message) do
        nil -> nil
        message -> render_one(message, __MODULE__, "message.json", as: :message)
      end

      IO.inspect(convo.group_avatar_url, label: "group_avatar_url")

    %{
      id: convo.id,
      is_group: convo.is_group,
      group_name: convo.group_name,
      group_avatar_url: convo.group_avatar_url, #Base.encode64(convo.group_avatar_url || <<>>),
      created_by: convo.creator.id,
      inserted_at: convo.inserted_at,
      updated_at: convo.updated_at,
      last_message: last_message,
      members: render_many(convo.conversation_members, WhatsappCloneWeb.UserView, "member.json")
    }
  end

  def render("message.json", %{message: nil}), do: nil

  def render("message.json", %{message: message}) do
    %{
      id: message.id,
      sender_id: message.sender_id,
      conversation_id: Map.get(message, :conversation_id), # add if needed
      encrypted_body: message.encrypted_body,
      message_type: message.message_type,
      inserted_at: message.inserted_at
    }
  end
  # defp safe_encode_avatar(nil), do: nil

  # defp safe_encode_avatar(binary) when is_binary(binary) do
  #   # Always encode raw binary to base64 with proper data URI prefix
  #   "data:image/png;base64," <> Base.encode64(binary)
  # end

  # defp safe_encode_avatar(_), do: nil



  defp render_last_message(%{messages: %Ecto.Association.NotLoaded{}}), do: nil
  defp render_last_message(%{messages: []}), do: nil

  defp render_last_message(%{messages: messages}) when is_list(messages) do
    case List.first(messages) do
      nil -> nil
      message -> extract_message_fields(message)
    end
  end

  defp render_last_message(%WhatsappClone.Conversation{messages: messages}) do
    render_last_message(%{messages: messages})
  end

  defp extract_message_fields(message) when is_map(message) do
    %{
      id: safe_get(message, :id) || safe_get(message, "id"),
      sender_id: safe_get(message, :sender_id) || safe_get(message, "sender_id"),
      encrypted_body: safe_get(message, :encrypted_body) || safe_get(message, "encrypted_body"),
      message_type: safe_get(message, :message_type) || safe_get(message, "message_type"),
      inserted_at: safe_get(message, :inserted_at) || safe_get(message, "inserted_at")
    }
  end

  defp extract_message_fields(_), do: nil

  defp safe_get(map, key) when is_atom(key) do
    Map.get(map, key) || Map.get(map, to_string(key))
  end

  defp safe_get(map, key) when is_binary(key) do
    Map.get(map, key) || Map.get(map, String.to_existing_atom(key))
  rescue
    ArgumentError -> nil
  end
end
