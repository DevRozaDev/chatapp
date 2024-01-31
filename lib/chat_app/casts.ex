defmodule ChatApp.Casts do
  @moduledoc """
  For data casts and validation.
  """

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  def cast_params(filters, types) do
    Ecto.Changeset.cast({%{}, types}, filters, Map.keys(types))
    |> Ecto.Changeset.apply_action(:update)
  end
end
