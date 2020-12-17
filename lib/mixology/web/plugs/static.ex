# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Web.Plugs.Static do
  alias Plug.Static

  def init(opts) do
    %{
      gzip?: Keyword.get(opts, :gzip, false),
      brotli?: Keyword.get(opts, :brotli, false),
      only_rules: Keyword.get(opts, :only, {[], []}),
      qs_cache: Keyword.get(opts, :cache_control_for_vsn_requests, "public, max-age=31536000"),
      et_cache: Keyword.get(opts, :cache_control_for_etags, "public"),
      et_generation: Keyword.get(opts, :etag_generation, nil),
      headers: Keyword.get(opts, :headers, %{}),
      content_types: Keyword.get(opts, :content_types, %{})
    }
  end

  def call(conn, opts) do
    config = Bonfire.Common.Config.get!(CommonsPub.Uploads)
    from = Keyword.fetch!(config, :directory)
    at = Plug.Router.Utils.split(Keyword.fetch!(config, :path))
    opts = Map.merge(opts, %{from: from, at: at})
    Static.call(conn, opts)
  end
end
