# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.MiscSchema do
  @moduledoc """
  Stuff without a clear module
  """
  use Absinthe.Schema.Notation

  alias ActivityPub.Fetcher

  object :web_metadata do
    field(:title, :string)
    field(:summary, :string)
    field(:image, :string)
    field(:embed_code, :string)
    field(:language, :string)
    field(:author, :string)
    field(:source, :string)
    field(:resource_type, :string)
  end

  object :fetched_object do
    field(:id, :string)
    field(:data, :json)
    field(:local, :boolean)
    field(:public, :boolean)
  end

  def fetch_web_metadata(%{url: url}, info) do
    case MoodleNet.MetadataScraper.fetch(url) do
      {:error, _} -> {:error, MoodleNet.Common.NotFoundError.new(url)}
      ret -> ret
    end
  end

  def fetch_object(%{url: url}, _info) do
    with {:ok, object} <- Fetcher.fetch_object_from_id(url) do
      ret = %{
        id: object.id,
        data: object.data,
        local: object.local,
        public: object.public
      }

      {:ok, ret}
    else
      {:error, e} -> {:error, e}
    end
  end

end
