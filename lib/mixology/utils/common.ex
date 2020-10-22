# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Common do
  alias CommonsPub.Repo

  def is_ulid(str) when is_binary(str) do
    with :error <- Ecto.ULID.dump(str) do
      false
    else
      _ -> true
    end
  end

  def is_ulid(_), do: false

  def keys_transform(map, opts \\ []) when is_binary(opts) do
    keys_transform(map, [opts])
  end

  def keys_transform(%Ecto.Association.NotLoaded{}, _) do
    nil
  end

  def keys_transform(map, opts) when is_struct(map) do
    Map.from_struct(map) |> Map.delete(:__meta__) |> keys_transform(opts)
  end

  def keys_transform(string_key_list, opts) when is_list(string_key_list) do
    string_key_list |> Enum.map(&keys_transform(&1, opts))
  end

  def keys_transform(map, opts) when is_map(map) do
    for {key, val} <- map,
        into: %{},
        do: {key_transform(key, opts), keys_transform(val, opts)}
  end

  def keys_transform(value, _), do: value

  def key_transform(thing, opts) when is_atom(thing) do
    if "to_string" in opts do
      Atom.to_string(thing) |> Recase.to_camel()
    else
      thing
    end
  end

  def key_transform(thing, opts) when is_binary(thing) do
    if "to_existing_atom" in opts do
      maybe_str_to_atom(Recase.to_snake(thing))
    else
      if "to_atom" in opts do
        String.to_atom(Recase.to_snake(thing))
      else
        thing |> Recase.to_camel()
      end
    end
  end

  def maybe_str_to_atom(str) do
    try do
      String.to_existing_atom(str)
    rescue
      ArgumentError -> str
    end
  end

  def maybe_str_to_atom!(str) do
    try do
      String.to_existing_atom(str)
    rescue
      ArgumentError -> nil
    end
  end

  ### pagination

  def paginate(query, _opts), do: query

  defp cursor_or_id(%{cursor: cursor}), do: cursor
  defp cursor_or_id(%{id: id}), do: id

  def page_info(results, id \\ &cursor_or_id/1) when is_list(results) do
    case results do
      [] -> nil
      [x] -> %{start_cursor: id.(x), end_cursor: id.(x)}
      [x | xs] -> %{start_cursor: id.(x), end_cursor: id.(List.last(xs))}
    end
  end

  # @doc "Optionally paginates a query according to a user's request"
  # def paginate(query, opts) do
  # end

  # defp paginate_before(query, nil), do: {:ok, query}

  # defp paginate_before(query, offset)
  # when is_integer(offset) and offset >= 0, do: {:ok, offset(query, ^offset)}

  # defp paginate_before_q(query) do
  #   where(q, [
  # end

  # defp paginate_limit(query, nil), do: {:ok, query}

  # defp paginate_limit(query, limit)
  # when is_integer(limit) and limit >= 0 and limit <= 100,
  #   do: {:ok, limit(query, ^limit)}

  # defp paginate_limit(query, limit)


end
