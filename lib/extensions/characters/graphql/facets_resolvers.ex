# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Character.GraphQL.FacetsResolvers do
  @moduledoc "These resolver functions are to be called by other modules that use character, for fields or foreign keys that are part of the character table rather than that module's table."

  # alias MoodleNet.{
  #   # Activities,
  #   # GraphQL,
  #   # Repo,
  #   # Resources,
  # }
  # alias MoodleNet.GraphQL.{
  #   # FetchFields,
  #   # FetchPage,
  #   # FetchPages,
  #   # ResolveField,
  #   # ResolvePage,
  #   # ResolvePages,
  #   # ResolveRootPage
  # }

  # alias CommonsPub.Character
  # alias CommonsPub.Character.{Characters, Queries}
  # alias MoodleNet.Resources.Resource
  # alias MoodleNet.Common.Enums
  alias Pointers

  alias MoodleNetWeb.GraphQL.{
    CommonResolver
    # FollowsResolver
  }

  def creator_edge(%{character: %{creator_id: id}}, _, info),
    do: MoodleNetWeb.GraphQL.UsersResolver.creator_edge(%{creator_id: id}, nil, info)

  def context_edge(%{character: %{context_id: id}}, _, info),
    do: CommonResolver.context_edge(%{context_id: id}, nil, info)

  def outbox_edge(%{character: %{outbox_id: id}}, page_opts, info),
    do: CommonsPub.Character.GraphQL.Resolver.outbox_edge(%{outbox_id: id}, page_opts, info)

  def is_public_edge(%{character: character}, _, _), do: {:ok, not is_nil(character.published_at)}

  def is_disabled_edge(%{character: character}, _, _),
    do: {:ok, not is_nil(character.disabled_at)}

  def is_hidden_edge(%{character: character}, _, _), do: {:ok, not is_nil(character.hidden_at)}
  def is_deleted_edge(%{character: character}, _, _), do: {:ok, not is_nil(character.deleted_at)}

  def follower_count_edge(%{character_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.FollowsResolver.follower_count_edge(%{id: id}, page_opts, info)

  def my_follow_edge(%{character_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.FollowsResolver.my_follow_edge(%{id: id}, page_opts, info)

  def followers_edge(%{character_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.FollowsResolver.followers_edge(%{id: id}, page_opts, info)

  def my_like_edge(%{character_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.LikesResolver.my_like_edge(%{id: id}, page_opts, info)

  def likers_edge(%{character_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.LikesResolver.likers_edge(%{id: id}, page_opts, info)

  def liker_count_edge(%{character_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.LikesResolver.liker_count_edge(%{id: id}, page_opts, info)

  def my_flag_edge(%{character_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.FlagsResolver.my_flag_edge(%{id: id}, page_opts, info)

  def flags_edge(%{character_id: id}, page_opts, info),
    do: MoodleNetWeb.GraphQL.FlagsResolver.flags_edge(%{id: id}, page_opts, info)

  def icon_content_edge(%{character: %{icon_id: id}}, _, info),
    do: MoodleNetWeb.GraphQL.UploadResolver.icon_content_edge(%{icon_id: id}, nil, info)

  def image_content_edge(%{character: %{image_id: id}}, _, info),
    do: MoodleNetWeb.GraphQL.UploadResolver.image_content_edge(%{image_id: id}, nil, info)

  def threads_edge(%{character_id: id}, %{} = page_opts, info),
    do: MoodleNetWeb.GraphQL.ThreadsResolver.threads_edge(%{id: id}, page_opts, info)
end
