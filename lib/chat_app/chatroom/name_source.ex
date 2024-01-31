defmodule ChatApp.Chatroom.NameSource do
  use Agent

  @doc """
  Starts a name generator.
  Source keyword to select the file with list of names.
  """
  def start_link(opts) do
    name_source = Keyword.get(opts, :source, "default.txt")

    Agent.start_link(fn -> get_values(name_source) end, opts)
  end

  @doc """
  Gets a random name from the list.
  """
  def get_one(name_source) do
    Agent.get(name_source, &Enum.random(&1))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def get_list(name_source) do
    Agent.get(name_source, & &1)
  end

  # Function for reading possible nicknames from file.

  # File formatting:
  defp get_values(source) do
    {:ok, root} = File.cwd()
    path = Path.join([root, "names", source])
    {:ok, contents} = File.read(path)
    contents |> String.split(["\n", "\r", "\r\n"], trim: true)
  end
end
