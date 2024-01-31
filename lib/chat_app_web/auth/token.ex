defmodule ChatAppWeb.Auth.Token do
  @moduledoc """
  Custom token implementation using Phoenix Token.
  """

  alias Phoenix.Token
  alias ChatAppWeb.Endpoint

  @token_salt "12Wzew//2qzaql"

  @type data :: map | keyword | binary | integer
  @type opts :: keyword

  # token = sign(%{chat_id: 1, nickname_id: 2, author: "John"})
  @spec sign(data, opts) :: binary
  def sign(data, opts \\ []) do
    Token.sign(Endpoint, @token_salt, data, opts)
  end

  # {:ok, map} = verify(token, max_age: :infinity)
  @spec verify(binary, opts) :: {:ok, map} | {:error, atom | binary}
  def verify(token, opts \\ []) do
    Token.verify(Endpoint, @token_salt, token, opts)
  end
end
