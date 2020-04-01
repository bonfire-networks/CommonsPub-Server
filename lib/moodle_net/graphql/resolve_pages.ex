defmodule MoodleNet.GraphQL.ResolvePages do
  @moduledoc """
  Encapsulates the flow of resolving a page in the presence of a
  single parent. We also currently use this as a stopgap while we
  finish implementing some things, trading speed for correctness.
  """

  @enforce_keys [:module, :fetcher, :context, :page_opts, :info]
  defstruct [
    :module, :fetcher, :context, :page_opts, :info,
    cursor_validators: [&Ecto.ULID.cast/1],
    batch_opts: %{default_limit: 10},
    single_opts: %{default_limit: 10},
  ]

  alias MoodleNet.GraphQL
  alias MoodleNet.GraphQL.ResolvePages
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def run(
    %ResolvePages{
      module: module,
      fetcher: fetcher,
      context: context,
      page_opts: page_opts,
      info: info,
      cursor_validators: validators,
      batch_opts: batch_opts,
      single_opts: single_opts,
    }
  ) do
    info2 = Map.take(info, [:context])
    if GraphQL.in_list?(info) do
      with {:ok, page_opts} <- GraphQL.limit_page_opts(page_opts, batch_opts) do
        batch {module, fetcher, {page_opts, info2}}, context, Pages.getter(context)
      end
    else
      with {:ok, page_opts} <- GraphQL.full_page_opts(page_opts, validators, single_opts) do
        apply(module, fetcher, [page_opts, info2, context])
      end
    end
  end

end
