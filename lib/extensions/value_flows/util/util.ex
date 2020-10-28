# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Util do
  @doc "conditionally update a map"
  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)

  def maybe_append(list, nil), do: list
  def maybe_append(list, value), do: [value | list]

  @doc "Replace a key in a map"
  def map_key_replace(%{} = map, key, new_key) do
    map
    |> Map.put(new_key, map[key])
    |> Map.delete(key)
  end

  # def try_tag_thing(user, thing, attrs) do
  #   IO.inspect(attrs)
  # end

  @doc """
  lookup tag from URL(s), to support vf-graphql mode
  """

  # def try_tag_thing(_user, thing, %{resource_classified_as: urls})
  #     when is_list(urls) and length(urls) > 0 do
  #   # todo: lookup tag by URL
  #   {:ok, thing}
  # end

  def try_tag_thing(user, thing, tags) do
    CommonsPub.Tag.TagThings.try_tag_thing(user, thing, tags)
  end


  def handle_changeset_errors(cs, attrs, fn_list) do
    Enum.reduce_while(fn_list, cs, fn cs_handler, cs ->
      case cs_handler.(cs, attrs) do
        {:error, reason} -> {:halt, {:error, reason}}
        cs -> {:cont, cs}
      end
    end )
    |> case do
      {:error, _} = e -> e
      cs -> {:ok, cs}
    end
  end
end
