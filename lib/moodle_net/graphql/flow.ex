# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL.Flow do
  @moduledoc """

  ## Introduction

  Our GraphQL resolvers have gotten a bit boilerplatey in the mad rush
  we had for a while at the beginning of the year. This module is an
  attempt to refactor out most of the boilerplate involved in
  implementing GraphQL resolvers.

  I worked out the commonalities of our many resolvers and noticed the
  common parameters are the number of parents and whether the result
  is a singular item or paged, leaving us six combinations:

  |       | No Parent  | One Parent  | Many Parents |
  | :---- | :--------- | :---------  | :----------- |
  | Field | Root Field | Child Field | Child Fields |
  | Page  | Root Page  | Child Page  | Child Pages  |

  It turns out that two of these require equivalent behaviour, so we
  can get the number of helper functions down to 5:

  |       | No Parent   | One Parent | Many Parents |
  | :---- | :---------- | :--------- | :----------- |
  | Field | `field`     | `field`    | `fields`     |
  | Page  | `root_page` | `page`     | `pages`      |

  If you are not sure whether there are one or many parents, there are
  many. Flow detects this for itself and routes to the single parent
  case at present. We are still deciding what to do here.

  ## Extras

  * `get_tuple_item` - useful for counts

  """
  alias MoodleNet.GraphQL
  alias MoodleNet.GraphQL.{Fields, Pages}
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  @doc """
  Encapsulates the flow for resolving a field in the absence of
  multiple parents.
  """
  @spec field(
    module :: atom,
    callback :: atom,
    context :: term,
    info :: map
  ) :: term
  def field(module, callback, context, info) do
    user = info.context.current_user
    apply(module, callback, [user, context])
  end

  @doc """
  Encapsulates the flow for resolving a field in the presence of
  potentially multiple parents.
  """
  @spec fields(
    module :: atom,
    callback :: atom,
    context :: term,
    info :: map
  ) :: term
  @spec fields(
    module :: atom,
    callback :: atom,
    context :: term,
    info :: map,
    opts :: Keyword.t
  ) :: term
  def fields(module, callback, context, info, opts \\ []) do
    user = info.context.current_user
    default = Keyword.get(opts, :default, nil)
    getter = Keyword.get(opts, :getter, Fields.getter(context, default))
    batch {module, callback, user}, context, getter
  end

  @doc """
  Encapsulates the flow of resolving a page in the absence of
  parents.
  """
  @spec root_page(
    module :: atom,
    callback :: atom,
    page_opts :: map,
    info :: map
  ) :: term
  @spec root_page(
    module :: atom,
    callback :: atom,
    page_opts :: map,
    info :: map,
    opts :: Keyword.t
  ) :: term
  def root_page(module, callback, page_opts, info, opts \\ []) do
    with {:ok, page_opts} <- GraphQL.full_page_opts(page_opts, opts) do
      apply(module, callback, [page_opts, GraphQL.current_user(info)])
    end
  end

  @doc """
  Encapsulates the flow of resolving a page in the presence of a
  single parent. We also currently use this as a stopgap while we
  finish implementing some things, trading speed for correctness.
  """
  def page(module, callback, page_opts, key, info, opts) do
    user = info.context.current_user
    with {:ok, page_opts} <- GraphQL.full_page_opts(page_opts, opts) do
      apply(module, callback, [page_opts, user, key])
    end
  end

  @doc """
  Encapsulates the flow of resolving pages in the presence of
  potentially many parents.
  """
  def pages(module, callback, page_opts, key, info, opts) do
    pages(module, callback, page_opts, key, info, opts, opts)
  end

  def pages(module, callback, page_opts, key, info, batch_opts, single_opts) do
    user = info.context.current_user
    if GraphQL.in_list?(info) do
      with {:ok, page_opts} <- GraphQL.limit_page_opts(page_opts, batch_opts) do
        batch {module, callback, {page_opts, user}}, key, Pages.getter(key)
      end
    else
      with {:ok, page_opts} <- GraphQL.full_page_opts(page_opts, single_opts) do
        apply(module, callback, [page_opts, user, key])
      end
    end
  end

  def get_tuple_item(map, key, index, default) do
    case Map.fetch(map, key) do
      {:ok, val} when is_tuple(val) -> {:ok, elem(val, index)}
      :error -> {:ok, default}
    end
  end

end
