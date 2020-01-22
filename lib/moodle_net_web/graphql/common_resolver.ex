# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommonResolver do

  alias Ecto.ULID
  alias MoodleNet.Common
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Likes.Like
  alias MoodleNet.Follows.Follow
  alias MoodleNet.Features.Feature
  alias MoodleNet.Threads.{Comment, Thread}
  alias MoodleNet.Batching.Edges
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Users.User
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def created_at_edge(%{id: id}, _, _), do: ULID.timestamp(id)

  def context_edge(%{context_id: id}, _, _info) do
    batch {__MODULE__, :batch_context_edge}, id, Edges.getter(id)
  end
  
  def batch_context_edge(_, ids) do
    {:ok, ptrs} = Pointers.many(id: ids)
    Edges.new(Pointers.follow!(ptrs), &(&1.id))
  end

  # defp preload_context(%{context: %NotLoaded{}}=me), do: Repo.preload(me, :context)
  # defp preload_context(%{context: %{}}=me), do: me
  # defp preload_context(me), do: Repo.preload(me, :context)

  # def loaded_context(%Community{}=community), do: Repo.preload(community, :actor)
  # def loaded_context(%Collection{}=collection), do: Repo.preload(collection, :actor)
  # def loaded_context(%User{}=user), do: Repo.preload(user, :actor)
  # def loaded_context(other), do: other

  # def tag(%{tag_id: id}, info) do
  #   {:ok, Fake.tag()}
  #   |> GraphQL.response(info)
  # end
  # def tag_category(%{tag_category_id: id}, info) do
  #   {:ok, Fake.tag_category()}
  #   |> GraphQL.response(info)
  # end
  # def tag_category(_, _, info) do
  #   {:ok, Fake.tag_category()}
  #   |> GraphQL.response(info)
  # end
  # def tagging(%{tagging_id: id}, info) do
  #   {:ok, Fake.tagging()}
  #   |> GraphQL.response(info)
  # end
  # def taggings(_, _, info) do
  #   {:ok, Fake.long_edge_list(&Fake.tagging/0)}
  #   |> GraphQL.response(info)
  # end

  def is_public_edge(parent, _, _), do: {:ok, not is_nil(parent.published_at)}
  def is_local_edge(%{is_local: is_local}, _, _), do: {:ok, is_local}
  def is_disabled_edge(parent, _, _), do: {:ok, not is_nil(parent.disabled_at)}
  def is_hidden_edge(parent, _, _), do: {:ok, not is_nil(parent.hidden_at)}
  def is_deleted_edge(parent, _, _), do: {:ok, not is_nil(parent.deleted_at)}

  # def followed(%Follow{}=follow,_,info)

  def delete(%{context_id: id},_info) do
    with {:ok, pointer} <- Pointers.one(id: id),
         context = Pointers.follow!(pointer),
         {:ok, delete_fn} <- ensure_delete_fn(context) do
      delete_fn.(context)
    end
  end

  defp ensure_delete_fn(%Community{}), do: {:ok, &MoodleNet.Communities.soft_delete/1}
  defp ensure_delete_fn(%Collection{}), do: {:ok, &MoodleNet.Collections.soft_delete/1}
  defp ensure_delete_fn(%Resource{}), do: {:ok, &MoodleNet.Resources.soft_delete/1}
  defp ensure_delete_fn(%Comment{}), do: {:ok, &MoodleNet.Threads.Comments.soft_delete/1}
  defp ensure_delete_fn(%Feature{}), do: {:ok, &MoodleNet.Features.soft_delete/1}
  defp ensure_delete_fn(%Thread{}), do: {:ok, &MoodleNet.Threads.soft_delete/1}
  defp ensure_delete_fn(%User{}), do: {:ok, &MoodleNet.Users.soft_delete/1}
  defp ensure_delete_fn(%Follow{}), do: {:ok, &MoodleNet.Follows.undo/1}
  defp ensure_delete_fn(%Like{}), do: {:ok, &MoodleNet.Likes.undo/1}
  defp ensure_delete_fn(_), do: GraphQL.not_permitted("delete")

  # def tag(_, _, info) do
  #   {:ok, Fake.tag()}
  #   |> GraphQL.response(info)
  # end

  # def create_tagging(_, info) do
  #   {:ok, Fake.tagging()}
  #   |> GraphQL.response(info)
  # end

  # def tags(parent, _, info) do
  #   {:ok, Fake.long_edge_list(&Fake.tagging/0)}
  #   |> GraphQL.response(info)
  # end

end
