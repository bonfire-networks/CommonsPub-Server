defmodule MoodleNetWeb.Helpers.Common do
  @doc "Returns a value from a map, or a fallback if not present"
  def e(map, key, fallback) do
    Map.get(map, key, fallback)
  end

  @doc "Returns a value from a nested map, or a fallback if not present"
  def e(map, key1, key2, fallback) do
    e(e(map, key1, %{}), key2, fallback)
  end

  def e(map, key1, key2, key3, fallback) do
    e(e(map, key1, key2, %{}), key3, fallback)
  end
end
