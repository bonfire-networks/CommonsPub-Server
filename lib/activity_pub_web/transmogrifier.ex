# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.Transmogrifier do
  @moduledoc """
  This module normalises outgoing data to conform with AS2/AP specs
  and handles incoming objects and activities
  """

  alias ActivityPub.Actor
  alias ActivityPub.Entity
  alias ActivityPub.Fetcher
  alias ActivityPub.Object
  alias ActivityPub.Utils
  require ActivityPub.Guards, as: APG
  require Logger

  @doc """
  Translates MN Entity to an AP compatible format
  """
  def prepare_outgoing(%{"type" => "Create", "object" => object_id} = data) do
    object =
      object_id
      |> Object.normalize()
      |> Map.get(:data)
      |> prepare_object

    data =
      data
      |> Map.put("object", object)
      |> Map.merge(Utils.make_json_ld_header())
      |> Map.delete("bcc")

    {:ok, data}
  end

  # TODO hack for mastodon accept and reject type activity formats
  def prepare_outgoing(%{"type" => _type} = data) do
    data =
      data
      |> Map.merge(Utils.make_json_ld_header())

    {:ok, data}
  end

  def prepare_outgoing(entity) when APG.is_entity(entity) do
    entity
    |> Entity.aspects()
    |> Enum.flat_map(&filter_by_aspect(entity, &1))
    |> Enum.into(%{})
    |> set_type(entity.type)
    |> set_context()
    |> set_streams(entity)
    |> set_public()
    |> maybe_inject_object()
    |> set_public_key(entity)
  end

  # We currently do not perform any transformations on objects
  def prepare_object(object), do: object

  def prepare_embedded(entity) do
    entity
    |> Entity.aspects()
    |> Enum.flat_map(&filter_by_aspect_embedded(entity, &1))
    |> Enum.into(%{})
    |> Map.delete("likersCount")
    |> set_type(entity.type)
    |> maybe_put_id(entity)
  end

  defp filter_by_aspect(entity, aspect) do
    fields_name = filter_fields_by_definition(aspect)

    entity
    |> Map.take(fields_name)
    |> Enum.concat(Entity.assocs(entity))
    |> Enum.filter(&filter_by_value/1)
    |> normalize()
    |> common_fields(entity)
    |> custom_fields(entity, aspect)
  end

  defp filter_by_aspect_embedded(entity, aspect) do
    fields_name = filter_fields_by_definition(aspect)

    entity
    |> Map.take(fields_name)
    |> Enum.concat(Entity.assocs(entity))
    |> Enum.filter(&filter_by_value/1)
    |> normalize()
  end

  defp common_fields(ret, entity) do
    ret
    |> Map.put("id", entity.id)
    |> Map.put("type", entity.type)
    |> Map.put("@context", entity["@context"])
    |> Map.delete("likersCount")
    |> Map.delete("attributedToInv")
  end

  defp maybe_put_id(%{"type" => "Image"} = ret, _entity), do: ret

  defp maybe_put_id(ret, entity), do: Map.put(ret, "id", entity.id)

  defp maybe_inject_object(%{"object" => object} = entity) when is_map(object) do
    object =
      object
      |> Map.put("@context", entity["@context"])
      |> Map.put("attributedTo", entity["actor"])
      |> Map.put("to", entity["to"])
      |> Map.put("cc", entity["cc"])

    entity
    |> Map.put("object", object)
  end

  defp maybe_inject_object(entity), do: entity

  defp custom_fields(ret, _entity, ActivityPub.ActorAspect) do
    ret
    |> add_endpoints()
  end

  defp custom_fields(ret, entity, _)
       when APG.has_type(entity, "CollectionPage")
       when APG.has_type(entity, "MoodleNet:Community")
       when APG.has_type(entity, "MoodleNet:Collection"),
       do: ret

  defp custom_fields(ret, entity, ActivityPub.CollectionAspect)
       when APG.has_type(entity, "CollectionPage"),
       do: ret

  defp custom_fields(ret, entity, ActivityPub.CollectionAspect) do
    ret
    |> Map.put("first", ActivityPub.CollectionPage.id(entity))

    # |> Map.delete("items")
  end

  defp custom_fields(ret, _, _), do: ret

  defp add_endpoints(ret) do
    endpoints = %{"sharedInbox" => ActivityPub.UrlBuilder.base_url() <> "/shared_inbox"}
    Map.put(ret, "endpoints", endpoints)
  end

  # FIXME this can be calculated in compilation time :)
  defp filter_fields_by_definition(aspect) do
    aspect.__aspect__(:fields)
    |> Enum.map(&aspect.__aspect__(:field, &1))
    |> Enum.reduce([], fn
      %{name: :items}, acc -> [:items | acc]
      %{virtual: true}, acc -> acc
      %{name: name}, acc -> [name | acc]
    end)
  end

  defp filter_by_value({_, nil}), do: false
  defp filter_by_value({_, []}), do: false
  defp filter_by_value({_, map}) when map == %{}, do: false
  defp filter_by_value({_, %ActivityPub.SQL.FieldNotLoaded{}}), do: false
  defp filter_by_value({_, %ActivityPub.SQL.AssociationNotLoaded{}}), do: false
  defp filter_by_value(_), do: true

  defp normalize(entity) do
    entity
    |> Enum.map(&normalize_key_value/1)
    |> Enum.into(%{})
  end

  defp normalize_key_value({key, value}),
    do: {Recase.to_camel(to_string(key)), normalize_value(value)}

  defp normalize_value(%{"und" => value} = map) when map_size(map) == 1 and is_binary(value),
    do: normalize_value(value)

  defp normalize_value([value]), do: normalize_value(value)

  defp normalize_value(list) when is_list(list),
    do: Enum.map(list, &normalize_value/1)

  defp normalize_value(entity) when APG.is_entity(entity) do
    case entity.type do
      ["Object", "Collection"] -> entity.id
      ["Object", _] -> prepare_embedded(entity)
      _ -> entity.id
    end
  end

  defp normalize_value(value), do: value

  defp set_type(json, type), do: Map.put(json, "type", custom_type(type))

  defp custom_type(["Object", "Collection"]), do: "Collection"
  defp custom_type(["Object", "Collection", "CollectionPage"]), do: "CollectionPage"
  defp custom_type(["Object", object_type]), do: object_type
  defp custom_type(["Object", "Actor", "Person"]), do: "Person"
  defp custom_type(["Object", "Activity", activity_type]), do: activity_type

  defp custom_type(type) do
    cond do
      "MoodleNet:Community" in type -> ["Group", "MoodleNet:Community"]
      "MoodleNet:Collection" in type -> ["Group", "MoodleNet:Collection"]
      "MoodleNet:EducationalResource" in type -> ["Page", "MoodleNet:EducationalResource"]
      true -> type
    end
  end

  @context [
    "https://www.w3.org/ns/activitystreams",
    "https://w3id.org/security/v1",
    %{
      "MoodleNet" => "http://vocab.moodle.net/",
      "@language" => "en",
      "Emoji" => "toot:Emoji",
      "Hashtag" => "as:Hashtag",
      "PropertyValue" => "schema:PropertyValue",
      "manuallyApprovesFollowers" => "as:manuallyApprovesFollowers",
      "schema" => "http://schema.org",
      "toot" => "http://joinmastodon.org/ns#",
      "totalItems" => "as:totalItems",
      "value" => "schema:value",
      "sensitive" => "as:sensitive"
    }
  ]
  defp set_context(json),
    do: Map.put(json, "@context", @context)

  defp set_streams(json, entity) when APG.has_type(entity, "MoodleNet:Community") do
    {streams, json} = Map.split(json, ["collections", "subcommunities"])
    Map.put(json, "streams", streams)
  end

  defp set_streams(json, entity) when APG.has_type(entity, "MoodleNet:Collection") do
    {streams, json} = Map.split(json, ["resources", "subcollections"])
    Map.put(json, "streams", streams)
  end

  defp set_streams(json, _entity), do: json

  defp set_public(%{"public" => true} = json) do
    json
    |> Map.delete("public")
    |> add_public_address()
  end

  defp set_public(%{"public" => false} = json), do: Map.delete(json, "public")
  defp set_public(json), do: json

  @public_address "https://www.w3.org/ns/activitystreams#Public"
  defp add_public_address(%{"to" => value} = json) when is_binary(value),
    do: Map.put(json, "to", [value, @public_address])

  defp add_public_address(%{"to" => list} = json) when is_list(list),
    do: Map.put(json, "to", [@public_address | list])

  defp add_public_address(json), do: Map.put(json, "to", @public_address)

  defp set_public_key(json, entity) when APG.has_aspect(entity, ActivityPub.ActorAspect) do
    {:ok, entity} = ActivityPub.Utils.ensure_keys_present(entity)
    {:ok, _, public_key} = ActivityPub.Keys.keys_from_pem(entity.keys)
    public_key = :public_key.pem_entry_encode(:SubjectPublicKeyInfo, public_key)
    public_key = :public_key.pem_encode([public_key])

    public_key = %{
      "id" => "#{entity.id}#main-key",
      "owner" => entity.id,
      "publicKeyPem" => public_key
    }

    json
    |> Map.put("publicKey", public_key)
  end

  defp set_public_key(json, _entity), do: json

  # incoming activities

  # TODO
  defp mastodon_follow_hack(_, _), do: {:error, nil}

  defp get_follow_activity(follow_object, followed) do
    with object_id when not is_nil(object_id) <- Utils.get_ap_id(follow_object),
         {_, %Object{} = activity} <- {:activity, Object.get_by_ap_id(object_id)} do
      {:ok, activity}
    else
      # Can't find the activity. This might a Mastodon 2.3 "Accept"
      {:activity, nil} ->
        mastodon_follow_hack(follow_object, followed)

      _ ->
        {:error, nil}
    end
  end

  def handle_incoming(%{"type" => "Create", "object" => object} = data) do
    data = Utils.normalize_params(data)
    {:ok, actor} = Actor.get_by_ap_id(data["actor"])

    params = %{
      to: data["to"],
      object: object,
      actor: actor.data,
      context: object["conversation"],
      local: false,
      published: data["published"],
      additional:
        Map.take(data, [
          "cc",
          "directMessage",
          "id"
        ])
    }

    ActivityPub.create(params)
  end

  def handle_incoming(
        %{"type" => "Follow", "object" => followed, "actor" => follower, "id" => id} = data
      ) do
    with {:ok, followed} <- Actor.get_by_ap_id(followed),
         {:ok, follower} <- Actor.get_by_ap_id(follower),
         {:ok, activity} <- ActivityPub.follow(follower, followed, id, false) do
      ActivityPub.accept(%{
        to: [follower["id"]],
        actor: followed,
        object: data,
        local: true
      })

      {:ok, activity}
    end
  end

  def handle_incoming(
        %{"type" => "Accept", "object" => follow_object, "actor" => _actor, "id" => _id} = data
      ) do
    with actor <- Fetcher.get_actor(data),
         {:ok, followed} <- Actor.get_by_ap_id(actor),
         {:ok, follow_activity} <- get_follow_activity(follow_object, followed) do
      ActivityPub.accept(%{
        to: follow_activity.data["to"],
        type: "Accept",
        actor: followed,
        object: follow_activity.data["id"],
        local: false
      })
    else
      _e -> :error
    end
  end

  # TODO: add reject

  def handle_incoming(
        %{
          "type" => "Undo",
          "object" => %{"type" => "Follow", "object" => followed},
          "actor" => follower,
          "id" => id
        } = _data
      ) do
    with {:ok, follower} <- Actor.get_by_ap_id(follower),
         {:ok, followed} <- Actor.get_by_ap_id(followed) do
      ActivityPub.unfollow(follower, followed, id, false)
    else
      _e -> :error
    end
  end

  def handle_incoming(data) do
    Logger.info("Unhandled activity. Storing...")

    {:ok, activity, _object} = Utils.insert_full_object(data)
    handle_object(activity)
  end

  @doc """
  Normalises and inserts an incoming AS2 object. Returns Object.
  """
  @collection_types ["Collection", "OrderedCollection", "CollectionPage", "OrderedCollectionPage"]
  def handle_object(%{"type" => type} = data) when type in @collection_types do
    with {:ok, object} <- Utils.prepare_data(data) do
      {:ok, object}
    else
      {:error, e} -> {:error, e}
    end
  end

  def handle_object(data) do
    with {:ok, object} <- Utils.prepare_data(data),
         {:ok, object} <- Object.insert(object) do
      {:ok, object}
    else
      {:error, e} -> {:error, e}
    end
  end
end
