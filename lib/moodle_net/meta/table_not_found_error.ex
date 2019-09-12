defmodule MoodleNet.Meta.TableNotFoundError do
  @enforce_keys [:table]
  defstruct @enforce_keys

  @type t :: %__MODULE__{ table: term() }

  @spec new(term()) :: t()
  def new(table), do: %__MODULE__{table: table}
end
