# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.ActivityPubView do
  @moduledoc """
  Even though store the data in AS format, some changes need to be applied to the entity before serving it in the AP REST response. This is done in this module.
  """

  use ActivityPubWeb, :view

  alias ActivityPub.Entity
  require ActivityPub.Guards, as: APG

  def render("show.json", %{entity: entity, conn: conn}) do
    # def render("activity_pub.json", %{entity: entity, conn: conn}) do
    entity
    |> Entity.aspects()
    |> Enum.flat_map(&filter_by_aspect(entity, &1, conn))
    |> Enum.into(%{})
    |> set_type(entity.type)
    |> set_context()
    |> set_streams(entity)
    |> set_public()
  end

  def prepare_embedded(entity) do
    entity
    |> Entity.aspects()
    |> Enum.flat_map(&filter_by_aspect(entity, &1))
    |> Enum.into(%{})
    |> Map.delete("likersCount")
    |> set_type(entity.type)
  end

  defp filter_by_aspect(entity, aspect, conn) do
    fields_name = filter_fields_by_definition(aspect)

    entity
    |> Map.take(fields_name)
    |> Enum.concat(Entity.assocs(entity))
    |> Enum.filter(&filter_by_value/1)
    |> normalize()
    |> common_fields(entity, conn)
    |> custom_fields(entity, aspect, conn)
  end

  defp filter_by_aspect(entity, aspect) do
    fields_name = filter_fields_by_definition(aspect)

    entity
    |> Map.take(fields_name)
    |> Enum.concat(Entity.assocs(entity))
    |> Enum.filter(&filter_by_value/1)
    |> normalize()
  end

  defp common_fields(ret, entity, _conn) do
    ret
    |> Map.put("id", entity.id)
    |> Map.put("type", entity.type)
    |> Map.put("@context", entity["@context"])
    |> Map.delete("likersCount")
  end

  defp custom_fields(ret, _entity, ActivityPub.ActorAspect, conn) do
    ret
    |> add_endpoints(conn)
  end

  defp custom_fields(ret, entity, _, _conn)
       when APG.has_type(entity, "CollectionPage")
       when APG.has_type(entity, "MoodleNet:Community")
       when APG.has_type(entity, "MoodleNet:Collection"),
       do: ret

  defp custom_fields(ret, entity, ActivityPub.CollectionAspect, _conn)
       when APG.has_type(entity, "CollectionPage"),
       do: ret

  defp custom_fields(ret, entity, ActivityPub.CollectionAspect, conn) do
    ret
    |> Map.put("first", ActivityPub.CollectionPage.id(entity))

    # |> Map.delete("items")
  end

  defp custom_fields(ret, _, _, _), do: ret

  defp add_endpoints(ret, conn) do
    endpoints = %{"sharedInbox" => Routes.shared_inbox_url(conn, :shared_inbox)}
    Map.put(ret, "endpoints", endpoints)
  end

  defp extension_fields(entity) do
    entity
    |> Entity.extension_fields()
    |> Enum.filter(&filter_by_value/1)
    |> Enum.map(&normalize_value/1)
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
      ["Object", "Image"] ->
        prepare_embedded(entity)

      ["Object", "Place"] ->
        prepare_embedded(entity)

      _ ->
        entity.id
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
end
