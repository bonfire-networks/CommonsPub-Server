# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommentsResolver do

  alias MoodleNet.{Comments, Fake, GraphQL}
  
  def comment(%{comment_id: id}, info), do: Comments.fetch_comment(id)

  def comment(parent, _, info) do
    {:ok, nil}
  end

  def comments(parent, _, info) do
    {:ok, GraphQL.edge_list([], 0)}
  end

  def thread(%{thread_id: id}, info) do
    {:ok, nil}
  end
  def thread(_,_, info) do
    {:ok, nil}
  end

  def threads(parent, _, info) do
    {:ok, GraphQL.edge_list([], 0)}
  end

  def create_thread(%{context_id: context_id, comment: attrs}, info) do
    {:ok, nil}
  end

  def create_reply(%{thread_id: thread, in_reply_to_id: reply_to, comment: attrs}, info) do
    {:ok, nil}
  end

  def update(%{comment_id: comment_id, comment: changes}, info) do
    {:ok, nil}
  end

  def context(parent, _, info) do
    {:ok, nil}
  end

  def last_activity(_, _, info) do
    {:ok, Fake.past_datetime()}
    |> GraphQL.response(info)
  end
end
