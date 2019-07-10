# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.CommentSchema do
  use Absinthe.Schema.Notation

  require ActivityPub.Guards, as: APG

  alias ActivityPub.SQL.Query
  alias MoodleNet.Comments
  alias MoodleNetWeb.GraphQL.Errors
  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver

  object :comment do
    field(:id, :string)
    field(:local_id, :integer)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:content, :string)
    field(:published, :string)
    field(:updated, :string)

    field(:author, :user, do: resolve(Resolver.with_assoc(:attributed_to, single: true)))

    field(:in_reply_to, :comment, do: resolve(Resolver.with_assoc(:in_reply_to, single: true)))

    field :replies, :comment_replies_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:comment_reply))
    end

    field :likers, :comment_likers_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:comment_liker))
    end

    field :flags, :comment_flags_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:comment_flags))
    end

    field(:context, :comment_context, do: resolve(Resolver.with_assoc(:context, single: true, preload_assoc_individually: true)))
  end

  union :comment_context do
    description("Where the comment resides")

    types([:collection, :community])

    resolve_type(fn
      e, _ when APG.has_type(e, "MoodleNet:Community") -> :community
      e, _ when APG.has_type(e, "MoodleNet:Collection") -> :collection
    end)
  end

  object :comment_replies_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:comment_replies_edge))
    field(:total_count, non_null(:integer))
  end

  object :comment_replies_edge do
    field(:cursor, non_null(:integer))
    field(:node, :comment)
  end

  object :comment_likers_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:comment_likers_edge))
    field(:total_count, non_null(:integer))
  end

  object :comment_likers_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
  end

  object :comment_flags_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:comment_flags_edge))
    field(:total_count, non_null(:integer))
  end

  object :comment_flags_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
  end

  input_object :comment_input do
    field(:content, non_null(:string))
  end

  def prepare([e | _] = list, fields) when APG.has_type(e, "Note") do
    Enum.map(list, &prepare(&1, fields))
  end

  def prepare(e, _fields) when APG.has_type(e, "Note") do
    Resolver.prepare_common_fields(e)
  end

  def create_thread(%{context_local_id: context_id} = args, info) do
    with {:ok, author} <- Resolver.current_actor(info),
         {:ok, context} <- fetch_create_comment_context(context_id),
         {:ok, comment} <- MoodleNet.create_thread(author, context, args.comment) do
      fields = Resolver.requested_fields(info)
      {:ok, prepare(comment, fields)}
    end
    |> Errors.handle_error()
  end

  def create_reply(%{in_reply_to_local_id: in_reply_to_id} = args, info)
      when is_integer(in_reply_to_id) do
    with {:ok, author} <- Resolver.current_actor(info),
         {:ok, in_reply_to} <- Resolver.fetch(in_reply_to_id, "Note"),
         {:ok, comment} <- MoodleNet.create_reply(author, in_reply_to, args.comment) do
      fields = Resolver.requested_fields(info)
      {:ok, prepare(comment, fields)}
    end
    |> Errors.handle_error()
  end

  defp fetch_create_comment_context(context_id) do
    Query.new()
    |> Query.where(local_id: context_id)
    |> Query.one()
    |> case do
      nil ->
        Errors.not_found_error(context_id, "Context")

      context
      when APG.has_type(context, "MoodleNet:Community")
      when APG.has_type(context, "MoodleNet:Collection") ->
        {:ok, context}

      _ ->
        Errors.not_found_error(context_id, "Context")
    end
  end

  def like_comment(%{local_id: comment_id}, info) do
    with {:ok, liker} <- Resolver.current_actor(info),
         {:ok, comment} <- Resolver.fetch(comment_id, "Note") do
      MoodleNet.like_comment(liker, comment)
    end
    |> Errors.handle_error()
  end

  def undo_like_comment(%{local_id: comment_id}, info) do
    with {:ok, actor} <- Resolver.current_actor(info),
         {:ok, comment} <- Resolver.fetch(comment_id, "Note") do
      MoodleNet.undo_like(actor, comment)
    end
    |> Errors.handle_error()
  end

  def flag_comment(%{local_id: comment_id, reason: reason}, info) do
    with {:ok, liker} <- Resolver.current_actor(info),
         {:ok, comment} <- Resolver.fetch(comment_id, "Note"),
         {:ok, _flag} <- Comments.flag(liker, comment, %{reason: reason}) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def undo_flag_comment(%{local_id: comment_id}, info) do
    with {:ok, actor} <- Resolver.current_actor(info),
         {:ok, comment} <- Resolver.fetch(comment_id, "Note"),
         {:ok, _flag} <- Comments.undo_flag(actor, comment) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def delete_comment(%{local_id: id}, info) do
    with {:ok, author} <- Resolver.current_actor(info),
         {:ok, comment} <- Resolver.fetch(id, "Note"),
         :ok <- MoodleNet.delete_comment(author, comment) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

end
