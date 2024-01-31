defmodule ChatApp.ChatDB do
  @moduledoc """
  Chat's database context.
  """

  import Ecto.Query, warn: false

  alias ChatApp.{Chat.Chat, Repo, Chat.Message, Chat.Nickname, Chat.Category}

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  # MESSAGE

  @doc """
  Gets all transactions for a specific chat.
  """
  @spec get_messages(integer() | String.t()) :: [Message.t()]
  def get_messages(chat_id) do
    query =
      from m in Message,
        join: n in Nickname,
        on: m.nickname_id == n.id,
        where: m.chat_id == ^chat_id,
        select: %{id: m.id, content: m.content, author: n.nickname, timestamp: m.inserted_at}

    Repo.all(query)
  end

  @spec last_message(integer() | String.t()) :: Message.t() | nil
  def last_message(chat_id) do
    query =
      from m in Message,
        where: m.chat_id == ^chat_id,
        order_by: [desc: m.id],
        limit: 1

    Repo.one(query)
  end

  @doc """
  Adds a new message to the database.

  Both nickname_id and chat_id should be part of attrs.
  """
  @spec create_message(map()) :: {:ok, Message.t()} | changeset_error
  def create_message(attrs) do
    %Message{}
    |> Message.create_changeset(attrs)
    |> Repo.insert()
  end

  # CHAT

  @spec create_chat(map()) :: {:ok, Chat.t()} | changeset_error
  def create_chat(attrs) do
    attrs = add_chat_category_id(attrs)

    changeset =
      %Chat{}
      |> IO.inspect()
      |> Chat.create_changeset(attrs)

    # TODO: Reduce db count to 2 by adding explicit select function
    case Repo.insert(changeset) do
      {:ok, chat} ->
        chat = get_chat!(chat.id)
        {:ok, chat}

      error ->
        error
    end
  end

  defp add_chat_category_id(%{"category" => category} = attrs) do
    case get_category(category) do
      %{id: category_id} ->
        Map.put(attrs, "category_id", category_id)

      nil ->
        attrs
    end
  end

  def get_chat!(id), do: Chat |> chat_select |> Repo.get!(id)

  @spec close_chat!(integer() | String.t()) :: Chat.t()
  def close_chat!(chat_id) do
    Repo.get!(Chat, chat_id)
    |> Ecto.Changeset.change(%{archived: true})
    |> Repo.update()
  end

  @spec close_all_chats() :: {integer(), nil}
  def close_all_chats() do
    query =
      from ch in Chat,
        where: ch.archived == false,
        update: [set: [archived: true]]

    Repo.update_all(query, [])
  end

  @spec get_chats(map()) :: [Chat.t()] | changeset_error
  def get_chats(modifiers \\ %{}) do
    Chat
    |> chat_scope(modifiers)
    |> chat_phrase(modifiers)
    |> chat_category(modifiers)
    |> chat_select
    |> Repo.all()
  end

  # Get scope of chats (archived, non archived, all)
  def chat_scope(query, %{archived: state}), do: where(query, [ch], ch.archived == ^state)
  def chat_scope(query, _modifiers), do: query

  # Get chats only with specific phrase
  def chat_phrase(query, %{contains: ""}), do: query

  def chat_phrase(query, %{contains: phrase}),
    do: from(ch in query, where: ilike(ch.topic, ^"%#{phrase}%"))

  def chat_phrase(query, _modifiers), do: query

  # Get chats only from specific categories
  def chat_category(query, %{category: []}), do: query

  def chat_category(query, %{category: categories}) do
    from ch in query,
      join: c in Category,
      on: c.id == ch.category_id,
      where: c.name in ^categories
  end

  def chat_category(query, _modifiers), do: query

  defp chat_select(query) do
    from ch in query,
      join: c in Category,
      on: c.id == ch.category_id,
      select: %{
        id: ch.id,
        topic: ch.topic,
        category: c.name,
        archived: ch.archived,
        timestamp: ch.inserted_at
      }
  end

  # NICKNAME

  @doc """
  Adds new nickname to the database.
  """
  @spec create_nickname(map()) :: {:ok, Nickname.t()} | changeset_error
  def create_nickname(attrs) do
    %Nickname{}
    |> Nickname.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Checks if given nickname already exists.
  """
  @spec nickname_exists?(String.t()) :: boolean
  def nickname_exists?(nickname) do
    Nickname
    |> where([n], n.nickname == ^nickname)
    |> Repo.exists?()
  end

  @doc """
  Checks if given nickname already exists and returns it.
  """
  @spec get_nickname(String.t()) :: Nickname.t() | nil
  def get_nickname(nickname) do
    Nickname
    |> where([n], n.nickname == ^nickname)
    |> Repo.one()
  end

  # CATEGORY

  @doc """
  Checks if given category already exists and returns it.
  """
  def get_category(category) do
    Category
    |> where([c], c.name == ^category)
    |> Repo.one()
  end
end
