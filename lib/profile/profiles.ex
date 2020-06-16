#  MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Profile.Profiles do
  alias MoodleNet.{Activities, Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.GraphQL.{Fields, Page}
  alias MoodleNet.Common.Contexts
  alias Profile
  alias Profile.Queries
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User
  alias MoodleNet.Workers.APPublishWorker
  alias Pointers.Pointer
  alias Pointers

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  @doc """
  Retrieves a single profile by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for profiles (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(Profile, filters))

  @doc """
  Retrieves a list of profiles by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for profiles (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Profile, filters))}

  def fields(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of profiles according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, %{}=page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(Profile, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of profiles according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(cursor_fn, group_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.pages Queries, Profile,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
  end



  ## mutations

  @spec create(User.t(), attrs :: map) :: {:ok, Profile.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, attrs) when is_map(attrs) do

    Repo.transact_with(fn ->

      with {:ok, profile} <- insert_profile(creator, attrs),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, profile, act_attrs),
           :ok <- publish(creator, profile, activity, :created)
        do
          {:ok, profile}
      end
    end)
  end


  defp insert_profile(creator, attrs) do
    cs = Profile.create_changeset(creator, attrs)
    IO.inspect(cs)
    with {:ok, profile} <- Repo.insert(cs), do: {:ok, profile }
  end


  @doc "Takes a Pointer to something and creates a Profile based on it"
  def add_profile_to(%User{} = user, %Pointer{} = pointer) do
    thing = MoodleNet.Meta.Pointers.follow!(pointer)
    if(is_nil(thing.profile_id)) do
      add_profile_to(user, thing)
    else 
      {:ok, %{ thing.profile | profileistic: thing }}
    end
  end

  @doc "Takes anything and creates a Profile based on it"
  def add_profile_to(%User{} = user, %{} = thing) do
    # IO.inspect(thing)
    thing_name = thing.__struct__
    thing_context_module = apply(thing_name, :context_module, [])

    profile_attrs = profileisation(thing_name, thing, thing_context_module)

    # IO.inspect(profile_attrs)
    # add_profile_to(user, pointer, %{}) 

    Repo.transact_with(fn ->
      with {:ok, profile} <- create(user, profile_attrs)
            do
              {:ok, profile }
      end
    end)

  end

  @doc "Transform the fields of any Thing into those of a profile. It is recommended to define a `profilesation/1` function (transforming the data similarly to `profileisation_default/2`) in your Thing's context module which will also be executed if present."
  def profileisation(thing_name, thing, thing_context_module) do
    attrs = profileisation_default(thing_name, thing)
    # IO.inspect(attrs)

    if(Kernel.function_exported?(thing_context_module, :profileisation, 1)) do
      # IO.inspect(function_exists_in: thing_context_module)
      apply(thing_context_module, :profileisation, [attrs])
    else
      attrs
    end
  end 

  @doc "Transform the generic fields of anything to be turned into a profile."
  def profileisation_default(thing_name, thing) do
    thing 
    |> Map.put(:facet, thing_name |> to_string() |> String.split(".") |> List.last) # use Thing name as Profile facet/trope
    |> Map.put(:profileistic, thing) # include the linked thing
    |> Map.delete(:id) # avoid reusing IDs
    |> Map.from_struct |> Map.delete(:__meta__) # convert to map
  end 


  defp publish(creator, profile, activity, :created) do
    feeds = [
      creator.outbox_id,
      Feeds.instance_outbox_id(),
    ]
    with :ok <- FeedActivities.publish(activity, feeds),
         {:ok, _} <- ap_publish("create", profile.id, creator.id, nil),
      do: :ok
  end


  defp publish(profile, :updated) do
    # TODO: wrong if edited by admin
    with {:ok, _} <- ap_publish("update", profile.id, profile.creator_id, nil),
      do: :ok
  end
  defp publish(profile, :deleted) do
    # TODO: wrong if edited by admin
    with {:ok, _} <- ap_publish("delete", profile.id, profile.creator_id, nil),
      do: :ok
  end

  defp ap_publish(verb, context_id, user_id, nil) do
    APPublishWorker.enqueue(verb, %{
      "context_id" => context_id,
      "user_id" => user_id,
    })
  end
  defp ap_publish(_, _, _), do: :ok

  # TODO: take the user who is performing the update
  @spec update(User.t(), Profile.t(), attrs :: map) :: {:ok, Profile.t()} | {:error, Changeset.t()}
  def update(%User{} = user, %Profile{} = profile, attrs) do
    Repo.transact_with(fn ->
      with {:ok, profile} <- Repo.update(Profile.update_changeset(profile, attrs)),
           {:ok, actor} <- Actors.update(user, profile.actor, attrs),
           :ok <- publish(profile, :updated) do
        {:ok, %{ profile | actor: actor }}
      end
    end)
  end
  

  def soft_delete(%Profile{} = profile) do
    Repo.transact_with(fn ->
      with {:ok, profile} <- Common.soft_delete(profile),
           :ok <- publish(profile, :deleted) do
        {:ok, profile}
      end
    end)
  end


  #TODO move these to a common module

  @doc "conditionally update a map" 
  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)



end
