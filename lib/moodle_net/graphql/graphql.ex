# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL do

  alias Absinthe.Resolution
  alias MoodleNet.Common
  alias MoodleNet.Access.{
    NotLoggedInError,
    NotPermittedError,
  }

  defprotocol Response do
    def to_response(self, info, path)
  end

  def response(value_or_tuple, resolution, path \\ [])

  def response({:ok, value}, %Resolution{}=info, path),
    do: {:ok, Response.to_response(value, info, path)}

  def response({:error, value}, %Resolution{}=info, path),
    do: {:error, Response.to_response(value, info, path)}

  def response(value, %Resolution{}=info, path),
    do: Response.to_response(value, info, path)

  def wanted(resolution, path \\ [])

  def wanted(%Resolution{}=info, path) do
    Resolution.project(info)
    |> reproject(path)
    |> Enum.map(& &1.schema_node.identifier)
  end

  def current_user(%Resolution{}=info) do
    case info.context.current_user do
      nil -> {:error, NotLoggedInError.new()}
      user -> {:ok, user}
    end
  end

  def guest_only(%Resolution{}=info) do
    case info.context.current_user do
      nil -> :ok
      user -> {:error, NotPermittedError.new()}
    end
  end

  def reproject(projection, []), do: projection
  def reproject(projection, [key | keys]) do
    case Enum.find(projection, &(&1.schema_node.identifier == key)) do
      nil -> []
      node -> reproject(node.selections, keys)
    end
  end

  def node_list(nodes, count) do
    page_info = Common.page_info(nodes)
    %{page_info: page_info, total_count: count, nodes: nodes}
  end
  def edge_list(items, count) do
    page_info = Common.page_info(items)
    edges = Enum.map(items, &edge/1)
    %{page_info: page_info, total_count: count, edges: edges}
  end

  defp edge(%{id: id}=node), do: %{cursor: id, node: node}

  def not_permitted(), do: {:error, NotPermittedError.new()}

end
