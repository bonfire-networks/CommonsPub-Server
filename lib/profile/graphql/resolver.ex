# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Profile.GraphQL.Resolver do
  alias MoodleNet.{
    Activities,
    GraphQL,
    Repo,
    Resources,
  }
  alias MoodleNet.GraphQL.{
    Flow,
    FetchFields,
    FetchPage,
    FetchPages,
    ResolveField,
    ResolvePage,
    ResolvePages,
    ResolveRootPage,
  }
  alias Profile
  alias Profile.{Profiles, Queries}
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Common.Enums
  alias Pointers

  ## resolvers

  def profile(%{profile_id: id}, info) do
    # IO.inspect(id)
    ResolveField.run(
      %ResolveField{
        module: __MODULE__,
        fetcher: :fetch_profile,
        context: id,
        info: info,
      }
    )
  end

  def profile(%{profile_id: id}, _, info) do
    profile(%{profile_id: id}, info)
  end

  def profile(opts, _, info) do
    # IO.inspect(opts)
    {:ok, nil}
  end

  def profiles(page_opts, info) do
    ResolveRootPage.run(
      %ResolveRootPage{
        module: __MODULE__,
        fetcher: :fetch_profiles,
        page_opts: page_opts,
        info: info,
        cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1], # popularity
      }
    )
  end

  ## fetchers

  def fetch_profile(info, id) do
    Profiles.one(
      user: GraphQL.current_user(info),
      id: id,
      preload: :actor
    )
  end

  def fetch_profiles(page_opts, info) do
    FetchPage.run(
      %FetchPage{
        queries: Profile.Queries,
        query: Profile,
        # cursor_fn: Profiles.cursor(:followers),
        page_opts: page_opts,
        base_filters: [user: GraphQL.current_user(info)],
        # data_filters: [page: [desc: [followers: page_opts]]],
      }
    )
  end

  # def profileistic_edge(%Profile{profileistic_id: id}, _, info), do: MoodleNetWeb.GraphQL.CommonResolver.context_edge(%{context_id: id}, nil, info)

  def resource_count_edge(%Profile{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_resource_count_edge, id, info, default: 0
  end

  def fetch_resource_count_edge(_, ids) do
    FetchFields.run(
      %FetchFields{
        queries: Resources.Queries,
        query: Resource,
        group_fn: &elem(&1, 0),
        map_fn: &elem(&1, 1),
        filters: [profile_id: ids, group_count: :profile_id],
      }
    )
  end


  ## finally the mutations...


  def create_profile(%{profile: attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
        attrs = Map.merge(attrs, %{is_public: true})
        Profiles.create(user, attrs)
      end
    end)
  end

  def add_profile_to(%{context_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, pointer} <- MoodleNet.Meta.Pointers.one(id: id) do
              Profiles.add_profile_to(me, pointer) 
      end
    end
  end

  def update_profile(%{profile: changes, profile_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, profile} <- profile(%{profile_id: id}, info) do
        cond do
          user.local_user.is_instance_admin ->
	    Profiles.update(user, profile, changes)

          profile.creator_id == user.id ->
	    Profiles.update(user, profile, changes)

          true -> GraphQL.not_permitted("update")
        end
      end
    end)
  end

  # def delete(%{profile_id: id}, info) do
  #   # Repo.transact_with(fn ->
  #   #   with {:ok, user} <- GraphQL.current_user(info),
  #   #        {:ok, actor} <- Users.fetch_actor(user),
  #   #        {:ok, profile} <- Profiles.fetch(id) do
  #   #     profile = Repo.preload(profile, :community)
  #   # 	permitted =
  #   # 	  user.is_instance_admin or
  #   #       profile.creator_id == actor.id or
  #   #       profile.community.creator_id == actor.id
  #   # 	if permitted do
  #   # 	  with {:ok, _} <- Profiles.soft_delete(profile), do: {:ok, true}
  #   # 	else
  #   # 	  GraphQL.not_permitted()
  #   #     end
  #   #   end
  #   # end)
  #   # |> GraphQL.response(info)
  #   {:ok, true}
  #   |> GraphQL.response(info)
  # end

  defp validate_profile_context(pointer) do
    if Pointers.table!(pointer).schema in valid_contexts() do
      :ok
    else
      GraphQL.not_permitted()
    end
  end

  defp valid_contexts do
    Keyword.fetch!(Application.get_env(:moodle_net, Profiles), :valid_contexts)
  end


  def creator_edge(%{profile: %{creator_id: id}}, _, info) do
    ActorsResolver.creator_edge(%{creator_id: id}, nil, info)
  end
end
