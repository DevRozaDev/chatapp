defmodule ChatAppWeb.ChatView do
  use ChatAppWeb, :view
  alias ChatAppWeb.ChatView

  def render("chat_identity.json", %{identity: identity}) do
    %{chat_id: identity.chat_id, nickname: identity.nickname, token: identity.token}
  end

  def render("chats.json", %{chats: chats}) do
    render_many(chats, ChatView, "chat.json")
  end

  def render("chat.json", %{chat: chat}) do
    %{
      id: chat.id,
      topic: chat.topic,
      category: chat.category,
      timestamp: chat.timestamp,
      archived: chat.archived
    }
  end

  def render("messages.json", %{messages: messages, chat_id: chat_id}) do
    %{chat_id: chat_id, messages: render_many(messages, ChatView, "message.json")}
  end

  def render("message.json", %{chat: message}) do
    %{
      id: message.id,
      timestamp: message.timestamp,
      content: message.content,
      author: message.author
    }
  end
end
