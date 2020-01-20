# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL do

  alias Absinthe.Resolution
  alias MoodleNet.Batching.{Edge, EdgesPage, EdgesPages, PageInfo}
  import MoodleNet.Common.Query, only: [match_admin: 0]

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

  def admin_or_not_permitted(%Resolution{}=info) do
    case info.context.current_user do
      match_admin() -> info.context.current_user
      _ -> not_permitted()
    end
  end

  def current_user(%Resolution{}=info), do: current_user_or_not_logged_in(info)

  def current_user_or_not_logged_in(%Resolution{}=info) do
    case info.context.current_user do
      nil -> not_logged_in()
      user -> {:ok, user}
    end
  end

  def current_user_or_empty_edge_list(%Resolution{}=info) do
    case info.context.current_user do
      nil -> {:ok, EdgesPage.new([], 0, &(&1))}
      user -> {:ok, user}
    end
  end

  def current_user_or(%Resolution{}=info, value) do
    case info.context.current_user do
      nil -> {:ok, value}
      user -> {:ok, user}
    end
  end

  def guest_only(%Resolution{}=info) do
    case info.context.current_user do
      nil -> :ok
      _user -> not_permitted()
    end
  end

  def reproject(projection, []), do: projection
  def reproject(projection, [key | keys]) do
    case Enum.find(projection, &(&1.schema_node.identifier == key)) do
      nil -> []
      node -> reproject(node.selections, keys)
    end
  end

  def feed_activities_page(activities, count) when is_integer(count) do
    edges = Enum.map(activities, &feed_activity_edge/1)
    page_info = PageInfo.new(edges)
    total_count = Enum.count(edges)
    EdgesPage.new(page_info, total_count, &(&1.id))
  end

  defp feed_activity_edge(node), do: Edge.new(node.activity, node.id)

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
