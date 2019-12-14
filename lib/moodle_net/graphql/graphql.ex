# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL do

  alias Absinthe.Resolution
  alias MoodleNet.Common

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

  def loader(%{context: %{loader: loader}}), do: loader

  def current_user(%Resolution{}=info) do
    case info.context.current_user do
      nil -> not_logged_in()
      user -> {:ok, user}
    end
  end

  def guest_only(%Resolution{}=info) do
    case info.context.current_user do
      nil -> :ok
      user -> not_permitted()
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

  def edge_list(items, count, cursor_fn \\ &(&1.id)) do
    page_info = Common.page_info(items)
    edges = Enum.map(items, &edge(&1, cursor_fn))
    %{page_info: page_info, total_count: count, edges: edges}
  end

  defp edge(node, cursor_fn), do: %{cursor: cursor_fn.(node), node: node}

  def feed_list(activities, count) do
    page_info = Common.page_info(activities)
    edges = Enum.map(activities, &feed_list_edge/1)
    %{page_info: page_info, total_count: count, edges: edges}
  end

  defp feed_list_edge(node), do: %{cursor: node.id, node: node.activity}

  alias MoodleNet.Access.{
    InvalidCredentialError,
    NotLoggedInError,
    NotPermittedError,
  }
  alias MoodleNet.Common.{
    NotFoundError,
  }

  def invalid_credential(), do: {:error, InvalidCredentialError.new()}

  def not_logged_in(), do: {:error, NotLoggedInError.new()}

  def not_permitted(verb \\ "do"), do: {:error, NotPermittedError.new(verb)}

  def not_found(), do: {:error, NotFoundError.new()}
end
