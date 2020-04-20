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
    single_opts: %{default_limit: 5, max_limit: 10},
    batch_opts: %{default_limit: 3, max_limit: 5},
    deep_opts: %{default_limit: 3, max_limit: 3},
  ]

  alias MoodleNet.GraphQL
  alias MoodleNet.GraphQL.{Pages, ResolvePages}
  import Absinthe.Resolution.Helpers, only: [async: 1, batch: 3]

  def run(%ResolvePages{info: info}=rp) do
    run(GraphQL.list_depth(info), Map.take(info, [:context]), rp)
  end

  defp run(0, info, rp), do: run_full(rp, info, rp.single_opts)
  defp run(1, info, rp), do: run_limit(rp, info, rp.batch_opts)
  defp run(_other, info, rp), do: run_limit(rp, info, rp.deep_opts)

  defp run_full(rp, info, opts) do
    GraphQL.full_page_opts(rp.page_opts, rp.cursor_validators, opts)
    |> run_callback(info, rp)
  end

  defp run_limit(rp, info, opts) do
    # async(fn ->
      GraphQL.limit_page_opts(rp.page_opts, opts)
      |> run_callback(info, rp)
    # end)
  end

  defp run_callback({:ok, page_opts}, info, rp) do
    apply(rp.module, rp.fetcher, [page_opts, info, rp.context])
  end

  defp run_callback(other, _, _) do
    IO.inspect(other: other)
    other
  end

end
