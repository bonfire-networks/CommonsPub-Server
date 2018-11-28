defmodule ActivityPub.ParseError do
  @moduledoc """
  Indicates an entity could not be parsed due to invalid data.
  """

  @type t :: %__MODULE__{
          key: String.t(),
          value: String.t(),
          message: String.t()
        }

  @enforce_keys [:key, :value, :message]
  defexception [:key, :value, :message]

  def message(%__MODULE__{} = e),
    do: "The field #{e.key} with value #{inspect(e.value)} could not be parsed: #{e.message}"
end
