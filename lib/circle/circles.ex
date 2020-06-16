#  MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Circle.Circles do
  alias MoodleNet.{Activities, Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.GraphQL.{Fields, Page}
  alias MoodleNet.Common.Contexts
  alias Circle
  alias Circle.Queries
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User
  alias MoodleNet.Workers.APPublishWorker
  alias Character.Characters
  alias Profile.Profiles

  @facet_name "Circle"

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  @doc """
  Retrieves a single circle by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for circles (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(Circle, filters))

  @doc """
  Retrieves a list of circles by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for circles (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Circle, filters))}

  def fields(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of circles according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, %{}=page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(Circle, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of circles according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(cursor_fn, group_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.pages Queries, Circle,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
  end


  ## mutations

  @spec create(User.t(), context :: any, attrs :: map) :: {:ok, Circle.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, context, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->

      attrs = Map.put(attrs, :facet, @facet_name)

      with {:ok, circle} <- insert_circle(attrs, context),
          {:ok, attrs} <- attrs_with_circle(attrs, circle),
          {:ok, profile} <- Profiles.create(creator, attrs),
          {:ok, character} <- Characters.create(creator, attrs)
          #  {:ok, character} <- Characters.thing_link(circle, character)
            do
        {:ok, %{ circle | character: character }}
      end
    end)
  end

  @spec create(User.t(), attrs :: map) :: {:ok, Circle.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->

      attrs = Map.put(attrs, :facet, @facet_name)

      with {:ok, circle} <- insert_circle(attrs),
          {:ok, attrs} <- attrs_with_circle(attrs, circle),
          {:ok, profile} <- Profiles.create(creator, attrs),
          {:ok, character} <- Characters.create(creator, attrs)
          # {:ok, character} <- Characters.thing_link(circle, character)
           do
            {:ok, %{ circle | character: character }}
      end
    end)
  end

  defp attrs_with_circle(attrs, circle) do
    attrs = Map.put(attrs, :id, circle.id)
    IO.inspect(attrs)
    {:ok, attrs}
  end

  defp insert_circle(attrs) do
    IO.inspect(attrs)
    cs = Circle.create_changeset(attrs)
    with {:ok, circle} <- Repo.insert(cs), do: {:ok, IO.inspect(circle) }
  end

  defp insert_circle(attrs, context) do
    cs = Circle.create_changeset(attrs, context)
    with {:ok, circle} <- Repo.insert(cs), do: {:ok, IO.inspect(circle)  }
  end

  # TODO: take the user who is performing the update
  @spec update(User.t(), Circle.t(), attrs :: map) :: {:ok, Circle.t()} | {:error, Changeset.t()}
  def update(%User{} = user, %Circle{} = circle, attrs) do
    Repo.transact_with(fn ->
      with {:ok, circle} <- Repo.update(Circle.update_changeset(circle, attrs)),
           {:ok, character} <- Characters.update(user, circle.character, attrs) # update linked character too
      do
        {:ok, %{ circle | character: character }}
      end
    end)
  end


end
