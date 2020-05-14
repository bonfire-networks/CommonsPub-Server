# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.Queries do
  import Ecto.Query

  alias MoodleNet.Uploads.Content

  def query(Content) do
    from c in Content, as: :content,
      left_join: u in assoc(c, :content_upload), as: :content_upload,
      left_join: m in assoc(c, :content_mirror), as: :content_mirror,
      preload: [content_upload: u, content_mirror: m]
  end

  def query(q, filters), do: filter(query(q), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(query, filter_or_filters)

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:deleted, nil}), do: where(q, [content: c], is_nil(c.deleted_at))
  def filter(q, {:deleted, :not_nil}), do: where(q, [content: c], not is_nil(c.deleted_at))
  def filter(q, {:deleted, false}), do: where(q, [content: c], is_nil(c.deleted_at))
  def filter(q, {:deleted, true}), do: where(q, [content: c], not is_nil(c.deleted_at))
  def filter(q, {:deleted, {:gte, %DateTime{}=time}}), do: where(q, [content: c], c.deleted_at >= ^time)
  def filter(q, {:deleted, {:lte, %DateTime{}=time}}), do: where(q, [content: c], c.deleted_at <= ^time)

  def filter(q, {:published, nil}), do: where(q, [content: c], is_nil(c.published_at))
  def filter(q, {:published, :not_nil}), do: where(q, [content: c], not is_nil(c.published_at))
  def filter(q, {:published, false}), do: where(q, [content: c], is_nil(c.published_at))
  def filter(q, {:published, true}), do: where(q, [content: c], not is_nil(c.published_at))

  # by field values

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [content: c], c.id == ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [content: c], c.id in ^ids)

  def filter(q, {:uploader, id}) when is_binary(id), do: where(q, [content: c], c.uploader_id == ^id)
  def filter(q, {:uploader, ids}) when is_list(ids), do: where(q, [content: c], c.uploader_id in ^ids)


end
