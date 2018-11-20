defmodule ActivityPub.Entity do
  use Ecto.Schema

  alias ActivityPub.{
    ObjectAspect,
    ActorAspect,
    ActivityAspect,
    CollectionAspect,
    CollectionPageAspect,
    LinkAspect
  }

  alias ActivityPub.{StringListType, Metadata, Types}

  @aspects [ObjectAspect, ActorAspect, ActivityAspect, CollectionAspect, CollectionPageAspect, LinkAspect]
  @behaviour Access
  @primary_key false

  embedded_schema do
    field(:"@context", :map)
    field(:id, :string)
    field(:type, StringListType)
    field(:local_id, :integer)

    for aspect <- @aspects do
      embeds_one(aspect.internal_field(), aspect)
    end

    embeds_one(:metadata, Metadata)

    field(:extension_fields, :map)
  end

  def parse(%{} = input) do
    input = normalize_input(input)
    types = input |> Map.get("type", "Object") |> List.wrap()
    # FIXME types can have [true, false] and it will crash, need cast!
    types =
      types
      |> Enum.flat_map(&Types.get_ancestors/1)
      |> Enum.uniq()


    aspects =
      types
      |> Enum.flat_map(&Types.get_aspects/1)
      |> Enum.uniq()

    metadata = Metadata.build(types)
    extension_fields = calc_extension_fields(aspects, input)

    ch =
      %__MODULE__{}
      # FIXME IRI is a type?
      |> Ecto.Changeset.cast(input, [:"@context", :id])
      |> Ecto.Changeset.change(
        type: types,
        extension_fields: extension_fields,
        metadata: metadata
      )

    Enum.reduce(aspects, ch, fn aspect, ch ->
      field = aspect.internal_field()

      case aspect.parse(input) do
        {:ok, object} ->
          Ecto.Changeset.put_embed(ch, field, object)

        {:error, _e} ->
          # FIXME improve errors!
          Ecto.Changeset.add_error(ch, field, "is invalid")
      end
    end)
    |> Ecto.Changeset.apply_action(:insert)
  end

  def add_type(%__MODULE__{type: types} = e, new_type) do
    if new_type in types do
      e
    else
      new_type
      |> Types.get_aspects()
      |> Enum.reduce(e, fn aspect, e -> add_aspect(e, aspect) end)
      |> Map.put(:type, [new_type | types])
      |> Map.update!(:meta, & Metadata.add_type(&1, new_type))
    end
  end

  for aspect <- @aspects do
    field = aspect.internal_field()

    defp add_aspect(%__MODULE__{} = e, unquote(aspect))
         when not is_nil(:erlang.map_get(unquote(field), e)),
         do: e

    defp add_aspect(%__MODULE__{} = e, unquote(aspect)),
      do: Map.put(e, unquote(field), struct!(unquote(aspect)))
  end

  for aspect <- @aspects do
    field = aspect.internal_field()

    defp remove_aspect(%__MODULE__{} = e, unquote(aspect))
         when is_nil(:erlang.map_get(unquote(field), e)),
         do: e

    defp remove_aspect(%__MODULE__{} = e, unquote(aspect)),
      do: Map.put(e, unquote(field), nil)
  end

  defp normalize_input(%{} = input) do
    input
    |> Enum.into(%{}, fn {key, value} ->
      key = key |> to_string() |> Recase.to_snake()
      {key, value}
    end)
  end

  for aspect <- @aspects do
    atom_fields = aspect.__schema__(:fields)
    string_fields = Enum.map(atom_fields, &to_string/1)
    name = aspect.internal_field()

    def fetch(%__MODULE__{} = e, key)
        when not is_nil(:erlang.map_get(unquote(name), e)) and is_atom(key) and
               key in unquote(atom_fields) do
      e
      |> Map.fetch!(unquote(name))
      |> Map.fetch(key)
    end

    def fetch(%__MODULE__{} = e, key)
        when not is_nil(:erlang.map_get(unquote(name), e)) and is_binary(key) and
               key in unquote(string_fields) do
      fetch(e, String.to_atom(key))
    end

    def get_and_update(%__MODULE__{} = e, key, f)
        when not is_nil(:erlang.map_get(unquote(name), e)) and is_atom(key) and
               key in unquote(atom_fields) do
      e
      |> Map.fetch!(unquote(name))
      |> get_and_update(key, f)
    end

    def get_and_update(%__MODULE__{} = e, key, f)
        when not is_nil(:erlang.map_get(unquote(name), e)) and is_binary(key) and
               key in unquote(string_fields) do
      get_and_update(e, String.to_atom(key), f)
    end

    def pop(%__MODULE__{} = e, key)
        when not is_nil(:erlang.map_get(unquote(name), e)) and is_atom(key) and
               key in unquote(atom_fields) do
      e
      |> Map.fetch!(unquote(name))
      |> pop(key)
    end

    def pop(%__MODULE__{} = e, key)
        when not is_nil(:erlang.map_get(unquote(name), e)) and is_binary(key) and
               key in unquote(string_fields) do
      pop(e, String.to_atom(key))
    end
  end

  def fetch(%__MODULE__{} = e, key) when key in [:"@context", :id, :type],
    do: Map.fetch(e, key)

  def fetch(%__MODULE__{} = e, key) when key in ~w(@context id type),
    do: Map.fetch(e, String.to_atom(key))

  def fetch(%__MODULE__{} = e, key) when is_atom(key), do: fetch(e, to_string(key))
  def fetch(%__MODULE__{extension_fields: map}, key) when is_binary(key), do: Map.fetch(map, key)

  def get_and_update(%__MODULE__{} = e, key, f) when is_atom(key),
    do: get_and_update(e, to_string(key), f)

  def get_and_update(%__MODULE__{extension_fields: map}, key, f) when is_binary(key),
    do: Map.get_and_update(map, key, f)

  def pop(%__MODULE__{} = e, key) when is_atom(key), do: pop(e, to_string(key))
  def pop(%__MODULE__{extension_fields: map}, key) when is_binary(key), do: Map.pop(map, key)

  defp calc_extension_fields(aspects, input) do
    parsed_fields =
      Enum.flat_map(aspects, fn a ->
        a.__schema__(:fields) |> Enum.map(&to_string/1)
      end)

    parsed_fields = ["id", "type", "@context"] ++ parsed_fields

    Enum.reduce(input, %{}, fn {key, value}, acc ->
      if key in parsed_fields, do: acc, else: Map.put(acc, key, value)
    end)
  end
end
