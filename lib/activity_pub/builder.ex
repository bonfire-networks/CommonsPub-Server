# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Builder do
  @moduledoc """
  Builds an `ActivityPub.Entity`. Delegated from `ActivityPub.new/1`.

  ## Example
  ```
  {:ok, entity} = ActivityPub.new(%{type: "Object", content: "hello world"})
  ```

  ## Normalizing `ActivityPub.Entity`

  The first thing we do is detect the `ActivityPub.Entity` type. From the type we can infer the `ActivityPub.Aspect`(s) implemented by the `ActivityPub.Entity` (using the conversion table in `ActivityPub.Types`).

  Once we know the `ActivityPub.Aspect`(s) that the `ActivityPub.Entity` implements, the `ActivityPub.Metadata` field is created.

  We then generate then an `ActivityPub.Entity`, with the metadata and some basic fields (`entity = %{__ap__: meta, id: params["id"], type: type, "@context": context}`).

  We then iterate for each implemented `ActivityPub.Aspect` passing the rest of the fields provided and the empty `ActivityPub.Entity`. Each `ActivityPub.Aspect` iterates each field and each `ActivityPub.Entity` that it has defined and it also _normalizes the values_ to add them to the `ActivityPub.Entity`. So each `ActivityPub.Aspect` deals with its fields and the rest of them are passed to the next `ActivityPub.Aspect`(s).

  If after iterating each `ActivityPub.Aspect` there are leftover fields that haven't been normalized and added to the final `ActivityPub.Entity`, these are considered _extension fields_ and added to the `Entity` using a string key.

  ## Normalizing values/fields of `ActivityPub.Entity`

  The process of normalizing values is important to simplify the code, to avoid repeated conditional code when working with such dynamic structures. So if an _entity_ was created using the library functions we can ensure that the 'to' property will be always an array (possibly empty), and elements would always be other _entities_, whether fully loaded or not. This simplifies the code a lot.

  Some examples of this normalization follow.

  ### Normalize _Natural Language Values_

  Please refer to the [ActivityStreams spec about natural language values](https://www.w3.org/TR/activitystreams-core/#naturalLanguageValues).

  For such translatable fields, if we receive just a string we convert it to: %{"und" => string} (meaning it's a [string in an unknown language](https://www.w3.org/TR/activitystreams-core/#fig-using-the-und-language-tag)). The goal is always to use a map to avoid the next conditional cluttering the code everytime we use a Natural Language Value: _if this value is a string do this, else if the value is a map do this other thing._

  Remember we started building a generic library for any kind of project, including those with multilingual content.

  ### No functional associations

  Most of the associations aren't functional, so they could be an array. However, when only one value is provided, the array is optional. When normalizing, the associations with only one value are wrapped in a list, to avoid having to check if it is a list or a single value.

  ### Partial object representation

  ActivityStreams `Objects` (whether they originate on another instance or are an association with another local `Object`) can be represented using:

  *   only the ID
  *   with a partial representation of the object (only some fields)
  *   with the full representation (all the fields of the original object are present).

  Even if it receives only an ID, the library creates a "full object" with only the ID and _Metadata_ indicating that it is _not loaded_. This avoids having to check if an object is a string or an `ActivityPub.Entity`. In the future we can add hooks to fetch the full `Object` from its originating instance (when necessary).

  #### Empty fields

  When a field isn't present but is defined in an `ActivityPub.Aspect` it is set to nil or [] (depending on if it's functional or not), to avoid having to check if the field is in the map or not before accessing it).

  """

  alias ActivityPub.{Entity, Context, Types, Metadata}
  alias ActivityPub.{BuildError, LanguageValueType}

  alias ActivityPub.SQL.AssociationNotLoaded

  require ActivityPub.Guards, as: APG

  def new(params \\ %{})

  def new(params) when is_list(params), do: params |> Enum.into(%{}) |> new()

  def new(params) when is_map(params) or is_list(params),
    do: build(:new, params, nil, nil)

  def update(entity, changes)
      when APG.is_entity(entity) and (is_map(changes) or is_list(changes)) do
    changes = normalize_keys(changes)

    # TODO update the context?
    with {:ok, changes} <- update_id(entity, changes),
         {:ok, changes} <- update_type(entity, changes),
         {:ok, entity, changes} <- merge_aspects_fields(entity, changes),
         :ok <- verify_not_assoc_updates(entity, changes),
         entity = update_extension_fields(entity, changes) do
      {:ok, entity}
    end
  end

  defp update_id(%{id: id}, %{"id" => id} = changes) do
    {:ok, Map.delete(changes, "id")}
  end

  defp update_id(_, %{"id" => id}) do
    {:error, %BuildError{path: [:id], value: id, message: "cannot be changed"}}
  end

  defp update_id(_, changes) do
    {:ok, changes}
  end

  defp update_type(%{type: types}, %{"type" => raw_types} = changes) do
    with {:ok, change_types} <- Types.build(raw_types) do
      if MapSet.equal?(MapSet.new(types), MapSet.new(change_types)) do
        {:ok, Map.delete(changes, "type")}
      else
        {:error, %BuildError{path: [:type], value: raw_types, message: "cannot be changed"}}
      end
    end
  end

  defp update_type(_, changes), do: {:ok, changes}

  def load(_params) do
  end

  defp build(:new, entity, _, _) when APG.is_entity(entity), do: {:ok, entity}

  defp build(:new, id, parent, _) when is_binary(id) and not is_nil(parent) do
    meta = Metadata.not_loaded()
    {:ok, %{__ap__: meta, id: id, type: :unknown}}
  end

  defp build(:new, params, parent, parent_key) when is_map(params),
    do: build_new(normalize_keys(params), parent, parent_key)

  defp build(:new, value, _, parent_key),
    do: {:error, %BuildError{path: [parent_key], value: value, message: "is invalid"}}

  # FIXME !!! This was commented to create CollectionPage
  # defp build_new(%{"id" => value}, _, parent_key) do
  #   msg = "is an autogenerated field"
  #   build_error("id", value, msg, parent_key)
  # end

  defp build_new(params, parent, parent_key) when is_map(params) do
    {raw_context, params} = Map.pop(params, "@context")
    {raw_type, params} = Map.pop(params, "type")

    with {:ok, context} <- context(:new, raw_context, parent),
         {:ok, type} <- Types.build(raw_type),
         meta = Metadata.new(type),
         entity = %{__ap__: meta, id: params["id"], type: type, "@context": context},
         {:ok, entity, params} <- merge_aspects_fields(entity, params),
         {:ok, entity, extension_fields} <- merge_aspects_assocs(entity, params),
         entity = Map.merge(entity, extension_fields) do
      {:ok, entity}
    else
      {:error, %BuildError{} = e} ->
        e = insert_parent_keys(e, parent_key)
        {:error, e}
    end
  end

  defp merge_aspects_fields(entity, params) do
    entity
    |> Entity.aspects()
    |> Enum.reduce_while({:ok, entity, params}, fn aspect, {:ok, entity, params} ->
      case merge_aspect_fields(aspect, entity, params) do
        {:ok, _, _} = ret -> {:cont, ret}
        {:error, _} = error -> {:halt, error}
      end
    end)
  end

  defp merge_aspect_fields(aspect, entity, params) do
    aspect.__aspect__(:fields)
    |> Enum.reduce_while({:ok, entity, params}, fn field_name, {:ok, entity, params} ->
      field_def = aspect.__aspect__(:field, field_name)

      case put_field(entity, params, field_def) do
        {:ok, _, _} = ret -> {:cont, ret}
        {:error, _} = error -> {:halt, error}
      end
    end)
  end

  defp put_field(entity, params, field_def) do
    case get_raw_value(params, field_def) do
      :not_found ->
        entity = Map.put_new(entity, field_def.name, field_def.default)
        {:ok, entity, params}

      {:ok, raw_value, params} ->
        with {:ok, entity} <- cast_and_put(entity, raw_value, field_def) do
          {:ok, entity, params}
        end

      {:error, _} = error ->
        error
    end
  end

  defp get_raw_value(params, %{type: LanguageValueType, name: key}) do
    {map_value, params} = Map.pop(params, "#{key}_map", :default)
    {value, params} = Map.pop(params, to_string(key), :default)

    case {value, map_value} do
      {:default, :default} ->
        :not_found

      {value, :default} ->
        {:ok, value, params}

      {:default, value} ->
        {:ok, value, params}

      value ->
        msg = "a language value cannot receive the string and map format at the same time"
        error = %BuildError{path: [key], value: value, message: msg}
        {:error, error}
    end
  end

  defp get_raw_value(params, field_def) do
    case Map.pop(params, to_string(field_def.name), :default) do
      {:default, _} ->
        :not_found

      {raw_value, params} ->
        {:ok, raw_value, params}
    end
  end

  # FIXME !!! This was commented to create CollectionPage
  # defp cast_and_put(_entity, raw_value, %{autogenerated: true} = field_def) do
  #   msg =  "is an autogenerated field, but data is received"
  #   field_name = to_string(field_def.name)
  #   error = %BuildError{path: [field_name], value: raw_value, message: msg}
  #   {:error, error}
  # end

  defp cast_and_put(entity, raw_value, %{type: LanguageValueType, functional: true} = field_def) do
    lang = entity[:"@context"].language

    with {:ok, value} <- LanguageValueType.cast(raw_value, lang) do
      {:ok, Map.put(entity, field_def.name, value)}
    else
      :error ->
        field_name = to_string(field_def.name)
        error = %BuildError{path: [field_name], value: raw_value, message: "is invalid"}
        {:error, error}
    end
  end

  defp cast_and_put(entity, raw_value, %{type: LanguageValueType, functional: false} = field_def) do
    lang = entity[:"@context"].language

    with {:ok, value} <- language_value_list_cast(List.wrap(raw_value), lang) do
      {:ok, Map.put(entity, field_def.name, value)}
    else
      :error ->
        field_name = to_string(field_def.name)
        error = %BuildError{path: [field_name], value: raw_value, message: "is invalid"}
        {:error, error}
    end
  end

  defp cast_and_put(entity, raw_value, field_def) do
    wrapped_raw_value = if field_def.functional, do: raw_value, else: List.wrap(raw_value)
    type = if field_def.functional, do: field_def.type, else: {:array, field_def.type}

    case Ecto.Type.cast(type, wrapped_raw_value) do
      {:ok, value} ->
        {:ok, Map.put(entity, field_def.name, value)}

      :error ->
        error = %BuildError{
          path: [to_string(field_def.name)],
          value: raw_value,
          message: "is invalid"
        }

        {:error, error}
    end
  end

  defp language_value_list_cast(list, lang) do
    Enum.reduce_while(list, [], fn raw_value, acc ->
      case LanguageValueType.cast(raw_value, lang) do
        {:ok, value} -> {:cont, [value | acc]}
        :error -> :error
      end
    end)
  end

  defp merge_aspects_assocs(entity, params) do
    entity
    |> Entity.aspects()
    |> Enum.reduce({:ok, entity, params}, &cast_assocs(&2, &1))
  end

  defp cast_assocs({:ok, entity, params}, aspect) do
    try do
      Enum.reduce(
        aspect.__aspect__(:associations),
        {:ok, entity, params},
        &cast_assoc(&2, aspect.__aspect__(:association, &1))
      )
    catch
      {:error, _} = ret -> ret
    end
  end

  defp cast_assocs(error, _aspect), do: error

  defp cast_assoc({:ok, entity, params}, assoc_info) do
    assoc_name = to_string(assoc_info.name)
    {raw_assoc, params} = Map.pop(params, assoc_name)

    if assoc_info.functional do
      cast_single_assoc(assoc_info, raw_assoc, entity, assoc_name)
    else
      cast_many_assoc(assoc_info, raw_assoc, entity)
    end
    |> case do
      {:ok, assoc} ->
        {:ok, Map.put(entity, assoc_info.name, assoc), params}

      error ->
        error
    end
  end

  defp cast_assoc(error, _), do: error

  defp cast_many_assoc(assoc_info, raw_assocs, entity) do
    assocs =
      raw_assocs
      |> List.wrap()
      |> Enum.with_index()
      |> Enum.reduce([], fn {raw_assoc, index}, acc ->
        case cast_single_assoc(assoc_info, raw_assoc, entity, "#{assoc_info.name}.#{index}") do
          {:ok, nil} -> acc
          {:ok, assoc} -> [assoc | acc]
          {:error, _} = error -> throw(error)
        end
      end)
      |> Enum.reverse()

    {:ok, assocs}
  end

  defp cast_single_assoc(%{autogenerated: true} = assoc_info, nil, entity, _key) do
    %{aspect: aspect, name: field_name} = assoc_info

    aspect.autogenerate(field_name, entity)
  end

  defp cast_single_assoc(%{autogenerated: true}, value, _, key) do
    msg = "is an autogenerated association, but data is received"
    build_error(key, value, msg)
  end

  defp cast_single_assoc(_, nil, _, _), do: {:ok, nil}

  defp cast_single_assoc(_assoc_info, %AssociationNotLoaded{local_id: id}, _entity, _key) do
    meta = Metadata.not_loaded(id)
    {:ok, %{__ap__: meta, id: nil, type: :unknown}}
  end

  defp cast_single_assoc(assoc_info, params, entity, key) do
    with {:ok, assoc} <- build(:new, params, entity, key),
         :ok <- verify_assoc_type(assoc, assoc_info.type, params, key),
         do: {:ok, assoc}
  end

  defp verify_assoc_type(_assoc, :any, _, _), do: :ok

  defp verify_assoc_type(assoc, _type, _, _) when APG.has_status(assoc, :not_loaded), do: :ok

  defp verify_assoc_type(assoc, type, _, _) when is_binary(type) and APG.has_type(assoc, type),
    do: :ok

  defp verify_assoc_type(assoc, type, params, key) when is_binary(type),
    do: build_verify_assoc_type_error(assoc, type, params, key)

  defp verify_assoc_type(assoc, type, params, key) when is_list(type) do
    if Enum.any?(type, &APG.has_type(assoc, &1)),
      do: :ok,
      else: build_verify_assoc_type_error(assoc, type, params, key)
  end

  defp build_verify_assoc_type_error(assoc, assoc_info, params, key) do
    msg = "has invalid type: #{inspect(assoc.type)}, expected: #{inspect(assoc_info.type)}"
    error = %BuildError{path: [key], value: params, message: msg}
    {:error, error}
  end

  defp context(:new, nil, nil), do: {:ok, Context.default()}
  defp context(:new, nil, parent), do: {:ok, parent[:"@context"]}
  defp context(:new, raw_context, _parent), do: Context.build(raw_context)


  defp verify_not_assoc_updates(entity, params) do
    entity
    |> Entity.aspects()
    |> Enum.reduce_while(:ok, fn aspect, :ok ->
      aspect.__aspect__(:associations)
      |> Enum.reduce_while(:ok, fn association_name, :ok ->
        association_name_str = to_string(association_name)
        if Map.has_key?(params, association_name_str) do
          value = params[association_name]
          msg = "association cannot be updated"
          error = %BuildError{path: [association_name], value: value, message: msg}
          {:halt, {:error, error}}
        else
          {:cont, :ok}
        end
      end)
      |> case do
        :ok -> {:cont, :ok}
        {:error, _} = error -> {:halt, error}
      end
    end)
  end

  defp update_extension_fields(entity, extension_fields) do
    Enum.reduce(extension_fields, entity, fn
      {key, nil}, entity -> Map.delete(entity, key)
      {key, value}, entity -> Map.put(entity, key, value)
    end)
  end

  defp build_error(key, value, message, parent_key \\ nil) do
    e =
      %BuildError{path: [key], value: value, message: message}
      |> insert_parent_keys(parent_key)

    {:error, e}
  end

  defp insert_parent_keys(%BuildError{} = e, nil), do: e

  defp insert_parent_keys(%BuildError{} = e, parent_key),
    do: %{e | path: [parent_key | e.path]}

  def normalize_keys(params) do
    params
    |> Enum.map(fn {key, value} -> {to_string(key), value} end)
    |> Enum.into(%{}, fn
      {"@" <> key, value} ->
        key = key |> Recase.to_snake()
        {"@#{key}", value}

      {"_" <> key, value} ->
        key = key |> Recase.to_snake()
        {"_#{key}", value}

      {key, value} ->
        key = key |> Recase.to_snake()
        {key, value}
    end)
  end
end
