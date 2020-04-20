# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Test.Automaton do
  @moduledoc "Pagination testing"
  import ExUnit.Assertions
  import MoodleNet.Test.Trendy
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNetWeb.Test.ConnHelpers
  import Zest

  def root_page_test(
    %{query: query,
      connection: conn,
      return_key: key,
      default_limit: default_limit,
      total_count: total,
      data: data,
      assert_fn: assert_fn,
      cursor_fn: cursor_fn,
      limit: limit,
      after: aft,
      before: bef,
    }=opts
  ) do
    vars = Map.get(opts, :vars, %{})
    assert is_map(vars)

    page1 = scope [page: 1, limit: :default] do
      page = query_page(query, conn, key, vars, default_limit, total, false, true, cursor_fn)
      each(data, page.edges, assert_fn)
      page
    end

    page_1 = scope [page: 1, limit: 10] do
      vars = Map.merge(vars, %{limit => 10})
      page = query_page(query, conn, key, vars, 10, total, false, true, cursor_fn)
      each(data, page.edges, assert_fn)
      page
    end

    page2 = scope [page: 2, limit: 9, after: 10] do
      vars = Map.merge(vars, %{limit => 9, aft => page_1.page_info.end_cursor})
      page = query_page(query, conn, key, vars, 9, total, true, true, cursor_fn)
      drop_each(data, page.edges, 10, assert_fn)
      page
    end

    page3 = scope [page: 3, limit: 10, after: 19] do
      vars = Map.merge(vars, %{limit => 10, aft => page2.page_info.end_cursor})
      page = query_page(query, conn, key, vars, 8, total, true, false, cursor_fn)
      drop_each(data, page.edges, 19, assert_fn)
      page
    end

    page_2 = scope [page: 2, limit: :default, after: default_limit] do
      vars = Map.merge(vars, %{aft => page1.page_info.end_cursor})
      page = query_page(query, conn, key, vars, default_limit, total, true, true, cursor_fn)
      drop_each(data, page.edges, default_limit, assert_fn)
      page
    end

    _page_3 = scope [page: 3, limit: :default, after: 2 * default_limit] do
      vars = Map.merge(vars, %{aft => page_2.page_info.end_cursor})
      page = query_page(query, conn, key, vars, 7, total, true, false, cursor_fn)
      drop_each(data, page.edges, 2 * default_limit, assert_fn)
      page
    end
  end

  def child_page_test(
    %{query: query,
      connection: conn,
      parent_key: parent_key,
      child_key: child_key,
      default_limit: default_limit,
      total_count: total,
      parent_data: parent_data,
      child_data: child_data,
      assert_parent: assert_parent,
      assert_child: assert_child,
      cursor_fn: cursor_fn,
      after: aft,
      before: bef,
      limit: limit,
    }=opts
  ) do
    vars = Map.get(opts, :vars, %{})
    count_key = Map.get(opts, :count_key)
    assert is_map(vars)

    page1 = scope [page: 1, limit: :default] do
      parent = assert_parent.(parent_data, grumble_post_key(query, conn, parent_key, vars))
      page = assert_page(parent[child_key], default_limit, total, false, true, cursor_fn)
      if not is_nil(count_key), do: assert(parent[count_key] == total)
      each(child_data, page.edges, assert_child)
      page
    end

    page_1 = scope [page: 1, limit: 10] do
      vars = Map.put(vars, limit, 10)
      parent = assert_parent.(parent_data, grumble_post_key(query, conn, parent_key, vars))
      page = assert_page(parent[child_key], 10, total, false, true, cursor_fn)
      if not is_nil(count_key), do: assert(parent[count_key] == total)
      each(child_data, page.edges, assert_child)
      page
    end

    page2 = scope [page: 2, limit: 9, after: 10] do
      vars = Map.merge(vars, %{limit => 9, aft => page_1.page_info.end_cursor})
      parent = assert_parent.(parent_data, grumble_post_key(query, conn, parent_key, vars))
      page = assert_page(parent[child_key], 9, total, true, true, cursor_fn) #TODO s/nil/true/
      if not is_nil(count_key), do: assert(parent[count_key] == total)
      drop_each(child_data, page.edges, 10, assert_child)
      page
    end

    page3 = scope [page: 3, limit: 10, after: 19] do
      vars = Map.merge(vars, %{limit => 10, aft => page2.page_info.end_cursor})
      parent = assert_parent.(parent_data, grumble_post_key(query, conn, parent_key, vars))
      page = assert_page(parent[child_key], 8, total, true, false, cursor_fn)
      if not is_nil(count_key), do: assert(parent[count_key] == total)
      drop_each(child_data, page.edges, 19, assert_child)
      page
    end

    page_2 = scope [page: 2, limit: :default, after: default_limit] do
      vars = Map.merge(vars, %{aft => page1.page_info.end_cursor})
      parent = assert_parent.(parent_data, grumble_post_key(query, conn, parent_key, vars))
      page = assert_page(parent[child_key], default_limit, total, true, true, cursor_fn)
      if not is_nil(count_key), do: assert(parent[count_key] == total)
      drop_each(child_data, page.edges, default_limit, assert_child)
      page
    end

    _page_3 = scope [page: 3, limit: :default, after: 2 * default_limit] do
      vars = Map.merge(vars, %{aft => page_2.page_info.end_cursor})
      parent = assert_parent.(parent_data, grumble_post_key(query, conn, parent_key, vars))
      page = assert_page(parent[child_key], default_limit, total, true, true, cursor_fn)
      if not is_nil(count_key), do: assert(parent[count_key] == total)
      drop_each(child_data, page.edges, 2* default_limit, assert_child)
      page
    end
  end

  defp query_page(query, conn, key, vars, count, total, prev, next, cursor_fn) do
    grumble_post_key(query, conn, key, vars)
    |> assert_page(count, total, prev, next, cursor_fn)
  end

  # defp query_child_page(query, conn, vars, parent_key, child_key, parent_assert, parent_data, child_assert) do
  #   parent = parent_assert(grumble_post_key(query, conn, parent_key, vars)
      
  # end

end
