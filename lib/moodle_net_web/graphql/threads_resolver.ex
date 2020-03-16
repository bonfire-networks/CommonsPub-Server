# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ThreadsResolver do

  alias MoodleNet.{GraphQL, Repo, Threads}
  alias MoodleNet.GraphQL.Flow
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Threads.Comments
  
  def thread(%{thread_id: id}, info), do: Threads.one(id: id, user: info.context.current_user)

  # edges
  
  def threads_edge(%{id: id}, %{}=page_opts, info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_threads_edge, page_opts, id, info, opts)
  end

  def fetch_threads_edge({page_opts, current_user}, ids) do
    {:ok, edges} = Threads.pages(
      &(&1.context_id),
      &(&1.id),
      page_opts,
      [user: current_user, context_id: ids],
      [join: :last_comment, order: :last_comment_desc, preload: :last_comment],
      [group_count: :context_id]
    )
    edges
  end

  def fetch_threads_edge(page_opts, current_user, ids) do
    Threads.page(
      &(&1.id),
      page_opts,
      [user: current_user, context_id: ids],
      [join: :last_comment, order: :last_comment_desc, preload: :last_comment]
    )
  end

  ## mutations

  def create_thread(%{context_id: context_id, comment: attrs}, info) do
    with {:ok, user} <- GraphQL.current_user(info) do
      Repo.transact_with(fn ->
        with {:ok, pointer} = Pointers.one(id: context_id),
             :ok <- validate_thread_context(pointer),
             context = Pointers.follow!(pointer),
             {:ok, thread} <- Threads.create(user, context, %{is_local: true}) do
          attrs = Map.put(attrs, :is_local, true)
          Comments.create(user, thread, attrs)
        end
      end)
    end
  end

  defp validate_thread_context(pointer) do
    if Pointers.table!(pointer).schema in valid_contexts() do
      :ok
    else
      GraphQL.not_permitted()
    end
  end

  defp valid_contexts() do
    Keyword.fetch!(Application.get_env(:moodle_net, Threads), :valid_contexts)
  end

  def last_activity_edge(_, _, _info), do: {:ok, DateTime.utc_now()}

end
