defmodule ActivityPub.EntityType do
  @behaviour Ecto.Type

  def type, do: :map

  # FIXME
  def cast(%Ecto.Association.NotLoaded{}), do: {:ok, []}
  def cast(list) do
    ret =
      list
      |> List.wrap()
      |> Enum.map(fn x ->
        case single_cast(x) do
          {:ok, value} -> value
          _ -> throw(:error)
        end
      end)

    {:ok, ret}
  catch
    :error -> :error
  end

  def single_cast(id) when is_binary(id) do
    case ActivityPub.IRI.validate(id) do
      :ok -> {:ok, id}
      _ -> :error
    end
  end

  def single_cast(%{__struct__: ActivityPub.Entity} = e), do: {:ok, e}
  def single_cast(map) when is_map(map), do: ActivityPub.Entity.parse(map)
  def single_cast(_), do: :error

  def load(map) when is_map(map) do
    case ActivityPub.Entity.parse(map) do
      {:ok, v} -> {:ok, v}
      _ -> :error
    end
  end

  def dump(%{__ap__: _} = e), do: e
  def dump(_), do: :error
end
