# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Util do
  @doc "conditionally update a map"
  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)

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
  def try_tag_thing(user, thing, %{resourceClassifiedAs: urls})
      when is_list(urls) and length(urls) > 0 do
    # todo: lookup tag by URL
    {:ok, thing}
  end

  @doc """
  tag IDs from a `tags` field
  """
  def try_tag_thing(user, thing, %{tags: tag_ids}) when is_binary(tag_ids) do
    tag_ids = MoodleNetWeb.Component.TagAutocomplete.tags_split(tag_ids)
    things_add_tags(user, thing, tag_ids)
  end

  def try_tag_thing(user, thing, %{tags: tag_ids})
      when is_list(tag_ids) and length(tag_ids) > 0 do
    things_add_tags(user, thing, tag_ids)
  end

  def try_tag_thing(user, thing, %{tags: tag_ids})
      when is_list(tag_ids) and length(tag_ids) > 0 do
    things_add_tags(user, thing, tag_ids)
  end

  @doc """
  otherwise maybe we have tagnames inline in the note?
  """
  def try_tag_thing(user, thing, %{note: text}) when bit_size(text) > 1 do
    # MoodleNetWeb.Component.TagAutocomplete.try_prefixes(text)
    # TODO
    {:ok, thing}
  end

  def try_tag_thing(user, thing, _) do
    {:ok, thing}
  end

  @doc """
  tag existing thing with one or multiple Taggables, Pointers, or anything that can be made taggable
  """
  def things_add_tags(user, thing, taggables) do
    with {ok, taggable} <- CommonsPub.Tag.TagThings.thing_attach_tags(user, thing, taggables) do
      {:ok, MoodleNet.Repo.preload(thing, :tags)}
    end
  end
end
