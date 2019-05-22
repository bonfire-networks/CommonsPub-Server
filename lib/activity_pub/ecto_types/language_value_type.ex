defmodule ActivityPub.LanguageValueType do
  @moduledoc """
  Ecto type to cast ActivityStream natural language values: https://www.w3.org/TR/activitystreams-core/#naturalLanguageValues
  """
  @behaviour Ecto.Type

  def type, do: {:map, :string}

  # FIXME
  def cast(s, lang \\ "und")
  def cast(nil, _), do: {:ok, %{}}
  def cast([], _), do: :error
  def cast(s, lang) when is_binary(s), do: cast(%{lang => s})
  def cast(s, _), do: Ecto.Type.cast(type(), s)

  def load(list), do: Ecto.Type.load(type(), list)
  def dump(list), do: Ecto.Type.dump(type(), list)
end
