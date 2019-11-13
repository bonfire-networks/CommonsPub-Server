# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommentsResolver do

  alias MoodleNet.{Comments, Fake, GraphQL}
  
  def comment(%{comment_id: id}, info) do
    {:ok, Fake.comment()}
    |> GraphQL.response(info)
  end

  def comments(parent, _, info) do
    {:ok, Fake.long_edge_list(&Fake.comment/0)}
    |> GraphQL.response(info)
  end

  def thread(%{thread_id: id}, info) do
    {:ok, Fake.thread()}
    |> GraphQL.response(info)
  end
  def thread(_,_, info) do
    {:ok, Fake.thread()}
    |> GraphQL.response(info)
  end

  def threads(parent, _, info) do
    {:ok, Fake.long_edge_list(&Fake.thread/0)}
    |> GraphQL.response(info)
  end

  def create_thread(%{context_id: context_id, comment: attrs}, info) do
    {:ok, Fake.comment()}
    |> GraphQL.response(info)
  end

  def create_reply(%{thread_id: thread, in_reply_to_id: reply_to, comment: attrs}, info) do
    {:ok, Fake.comment()}
    |> GraphQL.response(info)
  end

  def update(%{comment_id: comment_id, comment: changes}, info) do
    {:ok, Fake.comment()}
    |> GraphQL.response(info)
  end

  def context(parent, _, info) do
    {:ok, Fake.thread_context()}
    |> GraphQL.response(info)
  end

  def last_activity(_, _, info) do
    {:ok, Fake.past_datetime()}
    |> GraphQL.response(info)
  end
end
