defmodule CommonsPub.Web.GraphQL.MiscSchema do
  @moduledoc """
  GraphQL stuff without a clear module
  """
  use Absinthe.Schema.Notation

  object :web_metadata do
    field(:url, :string)
    field(:title, :string)
    field(:summary, :string)
    field(:image, :string)
    field(:embed_code, :string)
    field(:language, :string)
    field(:author, :string)
    field(:source, :string)
    field(:mime_type, :string)
    field(:embed_type, :string)
    field(:embed_code, :string)
  end

  object :fetched_object do
    field(:id, :string)
    field(:data, :json)
    field(:local, :boolean)
    field(:public, :boolean)
  end

  def fetch_web_metadata(%{url: url}, _info) do
    with {:error, _} <- CommonsPub.MetadataScraper.fetch(url) do
      {:error, CommonsPub.Common.Errors.NotFoundError.new()}
    end
  end

  def fetch_object(%{url: url}, _info) do
    with {:ok, object} <- ActivityPub.Fetcher.fetch_object_from_id(url) do
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
