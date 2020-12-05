# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Web.GraphQL.InstanceResolver do
  alias CommonsPub.{
    # Activities,
    Features,
    # GraphQL,
    Instance,
    Uploads
  }

  alias CommonsPub.Collections.Collection
  alias CommonsPub.Communities.Community
  # alias Bonfire.GraphQL
  alias Bonfire.GraphQL.{ResolveRootPage, FetchPage}

  def instance(_, _info) do
    {:ok,
     %{
       hostname: Instance.hostname(),
       description: Instance.description(),
       upload_icon_types: Uploads.allowed_media_types(Uploads.IconUploader),
       upload_image_types: Uploads.allowed_media_types(Uploads.ImageUploader),
       upload_resource_types: Uploads.allowed_media_types(Uploads.ResourceUploader),
       upload_max_bytes: Uploads.max_file_size()
     }}
  end

  def featured_communities(_, page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_featured_communities,
      page_opts: page_opts,
      info: info
    })
  end

  def fetch_featured_communities(page_opts, _info) do
    FetchPage.run(%FetchPage{
      queries: Features.Queries,
      query: Features.Feature,
      page_opts: page_opts,
      base_filters: [deleted: false, join: :context, table: Community],
      data_filters: [page: [desc: [created: page_opts]], preload: :context]
    })
  end

  def featured_collections(_, page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_featured_collections,
      page_opts: page_opts,
      info: info
    })
  end

  def fetch_featured_collections(page_opts, _info) do
    FetchPage.run(%FetchPage{
      queries: Features.Queries,
      query: Features.Feature,
      page_opts: page_opts,
      base_filters: [deleted: false, join: :context, table: Collection],
      data_filters: [page: [desc: [created: page_opts]], preload: :context]
    })
  end

  def instance_outbox_edge(_, page_opts, _info) do
    feed_id = CommonsPub.Feeds.instance_outbox_id()
    tables = CommonsPub.Instance.default_outbox_query_contexts()

    CommonsPub.Web.GraphQL.ActivitiesResolver.fetch_outbox_edge(feed_id, tables, page_opts)
  end
end
