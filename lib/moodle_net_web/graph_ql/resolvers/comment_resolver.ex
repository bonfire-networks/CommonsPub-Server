defmodule MoodleNetWeb.GraphQL.CommentResolver do
  require ActivityPub.Guards, as: APG
  alias MoodleNetWeb.GraphQL.Errors
  alias MoodleNet.{Accounts, OAuth}

  alias ActivityPub.SQL.Query
  alias MoodleNet.Comments
  alias MoodleNetWeb.GraphQL.Errors
  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver

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
