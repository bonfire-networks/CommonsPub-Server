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
    end)
    |> case do
      {:error, _} = e -> e
      cs -> {:ok, cs}
    end
  end

  def ap_prepare_activity("create", thing, object) do
    with context <-
           CommonsPub.ActivityPub.Utils.get_cached_actor_by_local_id!(Map.get(thing, :context_id)),
         actor <-
           CommonsPub.ActivityPub.Utils.get_cached_actor_by_local_id!(
             Map.get(thing, :creator_id) || Map.get(thing, :primary_accountable_id) ||
               Map.get(thing, :provider_id) || Map.get(thing, :receiver_id)
           ),
         ap_id <- CommonsPub.ActivityPub.Utils.generate_object_ap_id(thing),
         object <-
           Map.merge(object, %{
             "id" => ap_id,
             "icon" => Map.get(object, :image),
             "actor" => actor.ap_id,
             "attributedTo" => actor.ap_id,
             "context" => context.ap_id,
             "name" => Map.get(object, :name, Map.get(object, :label)),
             "summary" => Map.get(object, :note, Map.get(object, :summary))
           }),
         params = %{
           actor: actor,
           to: [CommonsPub.ActivityPub.Utils.public_uri(), context.ap_id],
           object: object,
           context: context.ap_id,
           additional: %{
             "cc" => [actor.data["followers"]]
           }
         },
         {:ok, activity} <- ActivityPub.create(params, thing.id) do
      IO.puts(Jason.encode!(deep_map_from_struct(activity)))

      if is_map_key(thing, :canonical_url) do
        Ecto.Changeset.change(thing, %{canonical_url: activity_object_id(activity)})
        |> CommonsPub.Repo.update()
      end

      {:ok, activity}
    else
      e -> {:error, e}
    end
  end

  def deep_map_from_struct(struct = %{__struct__: _}) do
    Map.from_struct(struct) |> Map.drop([:__meta__]) |> deep_map_from_struct()
  end

  def deep_map_from_struct(map = %{}) do
    map
    |> Enum.map(fn {k, v} -> {k, deep_map_from_struct(v)} end)
    |> Enum.into(%{})
  end

  def deep_map_from_struct(v) when is_tuple(v), do: v |> Tuple.to_list()
  def deep_map_from_struct(v), do: v

  def activity_object_id(%{object: object}) do
    activity_object_id(object)
  end

  def activity_object_id(%{"object" => object}) do
    activity_object_id(object)
  end

  def activity_object_id(%{data: data}) do
    activity_object_id(data)
  end

  def activity_object_id(%{"id" => id}) do
    id
  end
end
