defmodule ActivityPub.StringListType do
  @doc """
  FIXME: this module probably is not needed anymore
  """

  @behaviour Ecto.Type

  def type, do: {:array, :string}

  def cast(list) do
    list = List.wrap(list)
    Ecto.Type.cast(type(), list)
  end

  def load(list), do: Ecto.Type.load(type(), list)
  def dump(list), do: Ecto.Type.dump(type(), list)
end
