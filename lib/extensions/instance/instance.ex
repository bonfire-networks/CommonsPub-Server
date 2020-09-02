# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Instance do
  @moduledoc "A proxy for everything happening on this instance"

  def hostname(config \\ config()) do
    Keyword.fetch!(config, :hostname)
  end

  def description(config \\ config()) do
    Keyword.fetch!(config, :description)
  end

  def base_url(), do: Application.fetch_env!(:commons_pub, :base_url)

  @doc false
  def default_outbox_query_contexts(config \\ config()) do
    Keyword.fetch!(config, :default_outbox_query_contexts)
  end

  defp config(), do: Application.fetch_env!(:commons_pub, __MODULE__)
end
