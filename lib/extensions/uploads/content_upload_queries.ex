# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.ContentUploadQueries do

  alias MoodleNet.Uploads.ContentUpload
  import Ecto.Query

  def query(ContentUpload) do
    from m in ContentUpload, as: :upload
  end

  def query(q, filters), do: filter(query(q), filters)

  defp join_to(q, rel, jq \\ :left)
  defp join_to(q, rels, jq) when is_list(rels), do: Enum.reduce(rels, q, &join_to(&2, &1, jq))

  defp join_to(q, {table, jq}, _), do: join_to(q, table, jq)
  defp join_to(q, :content, jq), do: join(q, jq, [upload: u], c in assoc(u, :content), as: :content)


  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:join, {table, jq}}), do: join_to(q, table, jq)
  def filter(q, {:join, table}), do: join_to(q, table)

  def filter(q, {:deleted, nil}), do: where(q, [content: c], is_nil(c.deleted_at))
  def filter(q, {:deleted, :not_nil}), do: where(q, [content: c], not is_nil(c.deleted_at))
  def filter(q, {:deleted, false}), do: where(q, [content: c], is_nil(c.deleted_at))
  def filter(q, {:deleted, true}), do: where(q, [content: c], not is_nil(c.deleted_at))
  def filter(q, {:deleted, {:gte, %DateTime{}=time}}), do: where(q, [content: c], c.deleted_at >= ^time)
  def filter(q, {:deleted, {:lte, %DateTime{}=time}}), do: where(q, [content: c], c.deleted_at <= ^time)

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [upload: u], u.id == ^id)
  def filter(q, {:id, {:gte, id}}) when is_binary(id), do: where(q, [upload: u], u.id >= ^id)
  def filter(q, {:id, {:lte, id}}) when is_binary(id), do: where(q, [upload: u], u.id <= ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [upload: u], u.id in ^ids)

end
