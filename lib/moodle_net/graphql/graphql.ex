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
    cursor_fn = Map.get(opts, :cursor_fn, &(&1))
    with {:ok, page_opts} <- limit_page_opts(attrs, opts) do
      case attrs do
        %{before: b, after: a} when not is_nil(b) and not is_nil(a) ->
          {:error, %{message: "May not provide both before and after"}}

        %{after: a} when not is_nil(a) ->
          {:ok, Map.put(page_opts, :after, cursor_fn.(a))}

        %{before: b} when not is_nil(b) ->
          {:ok, Map.put(page_opts, :before, cursor_fn.(b))}

        %{} -> {:ok, page_opts}
      end
    end
  end

  @max_limit 100
  @min_limit 1
  @default_limit 25

  def limit_page_opts(attrs, opts \\ %{}) do
    max = Map.get(opts, :max_limit, @max_limit)
    min = Map.get(opts, :min_limit, @min_limit)
    default = Map.get(opts, :default_limit, @default_limit)
    limit = Map.get(attrs, :limit, default)
    if limit < min or limit > max do
      {:error, %{message: "Bad limit, must be between #{min} and #{max}"}}
    else
      {:ok, %{limit: limit}}
    end
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

  def cast_ulid(str), do: Ecto.ULID.cast(str)

  def cast_int(str), do: Ecto.Type.cast(:integer, str)

  def cast_int_ulid_id(id) do
    with [int, ulid] <- id,
         {:ok, _} <- cast_int(int),
         {:ok, _} <- cast_ulid(id) do
      {:ok, id}
    end
  end

end
