# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL do

  alias Absinthe.Resolution
  alias MoodleNet.Batching.EdgesPage
  import MoodleNet.Common.Query, only: [match_admin: 0]

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

  alias MoodleNet.Access.{
    InvalidCredentialError,
    NotLoggedInError,
    NotPermittedError,
  }
  alias MoodleNet.Common.NotFoundError

  def invalid_credential(), do: {:error, InvalidCredentialError.new()}

  def not_logged_in(), do: {:error, NotLoggedInError.new()}

  def not_permitted(verb \\ "do"), do: {:error, NotPermittedError.new(verb)}

  def not_found(), do: {:error, NotFoundError.new()}

end
