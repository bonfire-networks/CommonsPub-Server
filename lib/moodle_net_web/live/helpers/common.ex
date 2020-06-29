defmodule MoodleNetWeb.Helpers.Common do
  @doc "Returns a value, or a fallback if not present"
  def e(key, fallback) do
    if(!is_nil(key)) do
      key
    else
      fallback
    end
  end

  @doc "Returns a value from a map, or a fallback if not present"
  def e(map, key, fallback) do
    if(is_map(map)) do
      Map.get(map, key, fallback)
    else
      fallback
    end
  end

  @doc "Returns a value from a nested map, or a fallback if not present"
  def e(map, key1, key2, fallback) do
    e(e(map, key1, %{}), key2, fallback)
  end

  def e(map, key1, key2, key3, fallback) do
    e(e(map, key1, key2, %{}), key3, fallback)
  end
end
