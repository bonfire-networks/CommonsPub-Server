# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.Queries do
  import Ecto.Query

  alias MoodleNet.Uploads.Upload

  def query(Upload) do
    from u in Upload, as: :upload
  end

  def query(q, filters), do: filter(query(q), filters)

  def queries(query, base_filters, data_filters, count_filters) do
    base_q = query(query, base_filters)
    data_q = filter(base_q, data_filters)
    count_q = filter(base_q, count_filters)
    {data_q, count_q}
  end

  def join_to(q, table_or_tables, jq \\ :left)

  ## many

  def join_to(q, tables, jq) when is_list(tables) do
    Enum.reduce(tables, q, &join_to(&2, &1, jq))
  end

  def join_to(q, :last_comment, jq) do
    join q, jq, [thread: t], c in LastComment, as: :last_comment
  end

  def join_to(q, :follower_count, jq) do
    join q, jq, [thread: t], c in FollowerCount, as: :follower_count
  end

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by join

  def filter(q, {:join, {rel, jq}}), do: join_to(q, rel, jq)

  def filter(q, {:join, rel}), do: join_to(q, rel)

  ## by status
  
  def filter(q, :deleted) do
    where q, [thread: t], is_nil(t.deleted_at)
  end

  def filter(q, :private) do
    where q, [thread: t], not is_nil(t.published_at)
  end

  # by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [upload: u], u.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [upload: u], u.id in ^ids
  end

  def filter(q, {:parent_id, id}) when is_binary(id) do
    where q, [upload: u], u.parent_id == ^id
  end

  def filter(q, {:parent_id, ids}) when is_list(ids) do
    where q, [upload: u], u.parent_id in ^ids
  end

  def filter(q, {:uploader_id, id}) when is_binary(id) do
    where q, [upload: u], u.uploader_id == ^id
  end

  def filter(q, {:uploader_id, ids}) when is_list(ids) do
    where q, [upload: u], u.uploader_id in ^ids
  end

  def filter(q, {:path, path}) when is_binary(path) do
    where q, [upload: u], u.path == ^path
  end

  def filter(q, {:path, paths}) when is_list(paths) do
    where q, [upload: u], u.path in ^paths
  end

end
