# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL do

  alias Absinthe.Resolution
  alias Ecto.Changeset
  alias MoodleNet.GraphQL.{Page, PageOpts}
  import MoodleNet.Common.Query, only: [match_admin: 0]

  def reverse_path(info) do
    Enum.reverse(Resolution.path(info))
  end

  # If there is a list anywhere further up the query, we're in a list
  def in_list?(info), do: Enum.any?(Resolution.path(info), &is_integer/1)

  def parent_name(resolution) do
    resolution.path
  end

  def wanted(resolution, path \\ [])

  def wanted(%Resolution{}=info, path) do
    Resolution.project(info)
    |> reproject(path)
    |> Enum.map(& &1.schema_node.identifier)
  end

  def admin_or_not_permitted(%Resolution{}=info) do
    case info.context.current_user do
      match_admin() -> {:ok, info.context.current_user}
      _ -> not_permitted()
    end
  end
  def current_user(info), do: info.context.current_user

  def current_user_or(info, value), do: lazy_or(current_user(info), value)

  def current_user_or_empty_page(info), do: current_user_or(info, &empty_page/0)

  def current_user_or_not_logged_in(info), do: current_user_or(info, &not_logged_in/0)

  def current_user_or_not_found(info), do: current_user_or(info, &not_found/0)

  def admin_or_not_permitted(%Resolution{}=info) do
    case current_user(info) do
      match_admin() -> current_user(info)
      _ -> not_permitted()
    end
  end

  defp lazy_or(nil, lazy) when is_function(lazy, 0), do: lazy_or(nil, lazy.())
  defp lazy_or(nil, {:ok, value}), do: {:ok, value}
  defp lazy_or(nil, {:error, value}), do: {:error, value}
  defp lazy_or(nil, value), do: {:ok, value}
  defp lazy_or(value, _), do: {:ok, value}

  def guest_only(%Resolution{}=info) do
    case current_user(info) do
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

  def full_page_opts(attrs, opts \\ %{}) do
    Changeset.apply_action(PageOpts.full_changeset(attrs, opts), :create)
  end

  def limit_page_opts(attrs, opts \\ %{}) do
    Changeset.apply_action(PageOpts.limit_changeset(attrs, opts), :create)
  end

  def empty_page(), do: Page.new([], 0, &(&1), %{})

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
