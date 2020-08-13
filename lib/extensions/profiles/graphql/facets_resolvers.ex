# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Profile.GraphQL.FacetsResolvers do
  @moduledoc "These resolver functions are to be called by other modules that use Profile, for fields or foreign keys that are part of the Profile table rather than that module's table."

  alias Profile
  alias Pointers

  def creator_edge(%{profile: %{creator_id: id}}, _, info),
    do: MoodleNetWeb.GraphQL.UsersResolver.creator_edge(%{creator_id: id}, nil, info)

  def is_public_edge(%{profile: profile}, _, _), do: {:ok, not is_nil(profile.published_at)}
  def is_disabled_edge(%{profile: profile}, _, _), do: {:ok, not is_nil(profile.disabled_at)}
  def is_hidden_edge(%{profile: profile}, _, _), do: {:ok, not is_nil(profile.hidden_at)}
  def is_deleted_edge(%{profile: profile}, _, _), do: {:ok, not is_nil(profile.deleted_at)}

  def my_like_edge(%{profile_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.LikesResolver.my_like_edge(%{id: id}, page_opts, info)

  def likers_edge(%{profile_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.LikesResolver.likers_edge(%{id: id}, page_opts, info)

  def liker_count_edge(%{profile_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.LikesResolver.liker_count_edge(%{id: id}, page_opts, info)

  def my_flag_edge(%{profile_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.FlagsResolver.my_flag_edge(%{id: id}, page_opts, info)

  def flags_edge(%{profile_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.FlagsResolver.flags_edge(%{id: id}, page_opts, info)

  def icon_content_edge(%{profile: %{icon_id: id}}, _, info),
    do: MoodleNetWeb.GraphQL.UploadResolver.icon_content_edge(%{icon_id: id}, nil, info)

  def image_content_edge(%{profile: %{image_id: id}}, _, info),
    do: MoodleNetWeb.GraphQL.UploadResolver.image_content_edge(%{image_id: id}, nil, info)
end
