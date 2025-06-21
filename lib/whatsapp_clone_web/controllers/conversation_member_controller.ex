defmodule WhatsappCloneWeb.ConversationMemberController do
  import Ecto.Query, only: [from: 2]

  use WhatsappCloneWeb, :controller
  alias WhatsappClone.{Repo, ConversationMember, Conversations}

  action_fallback WhatsappCloneWeb.FallbackController

  @doc """
  POST /api/conversations/:conversation_id/members
  Body params: %{"user_id" => "...", "is_admin" => true|false}
  """
  def create(conn, %{"conversation_id" => conversation_id, "user_id" => user_id, "is_admin" => is_admin}) do
    # Only allow if current user is admin of that conversation
    current_user = conn.assigns[:user_id]

    if Conversations.user_in_conversation?(current_user, conversation_id) do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      attrs = %{
        "conversation_id" => conversation_id,
        "user_id" => user_id,
        "joined_at" => now,
        "is_admin" => is_admin
      }

      %ConversationMember{}
      |> ConversationMember.changeset(attrs)
      |> Repo.insert()
      |> case do
        {:ok, member} ->
          json(conn, %{member: %{id: member.id, user_id: member.user_id, is_admin: member.is_admin}})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: render_changeset_errors(changeset)})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Not a member of this conversation"})
    end
  end

  @doc """
  DELETE /api/conversations/:conversation_id/members/:user_id
  Removes a user from a conversation.
  """
  def delete(conn, %{"conversation_id" => conversation_id, "user_id" => user_id}) do
    current_user = conn.assigns[:user_id]

    if Conversations.user_in_conversation?(current_user, conversation_id) do
      case Repo.get_by(ConversationMember, conversation_id: conversation_id, user_id: user_id) do
        nil ->
          send_resp(conn, 404, "Member not found")

        member ->
          Repo.delete(member)
          send_resp(conn, 204, "")
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Not a member of this conversation"})
    end
  end

  @doc """
  PATCH /api/conversations/:conversation_id/members/:user_id
  Body params: %{"is_admin" => true|false}
  """
  def update(conn, %{"conversation_id" => conversation_id, "user_id" => user_id, "is_admin" => is_admin}) do
    current_user = conn.assigns[:user_id]

    if Conversations.user_in_conversation?(current_user, conversation_id) do
      case Repo.get_by(ConversationMember, conversation_id: conversation_id, user_id: user_id) do
        nil ->
          send_resp(conn, 404, "Member not found")

        member ->
          member
          |> ConversationMember.changeset(%{"is_admin" => is_admin})
          |> Repo.update()
          |> case do
            {:ok, updated} ->
              json(conn, %{member: %{id: updated.id, user_id: updated.user_id, is_admin: updated.is_admin}})

            {:error, changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{errors: render_changeset_errors(changeset)})
          end
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Not a member of this conversation"})
    end
  end

  def unread_count(conversation_id, user_id) do
    from(m in Message,
      join: cm in ConversationMember,
      on: cm.conversation_id == m.conversation_id and cm.user_id == ^user_id,
      where: m.conversation_id == ^conversation_id,
      where: is_nil(cm.last_read_at) or m.inserted_at > cm.last_read_at,
      select: count(m.id)
    )
    |> Repo.one()
  end






  defp render_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
