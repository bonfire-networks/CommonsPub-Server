# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.Schema do
  @moduledoc "Root GraphQL Schema"
  use Absinthe.Schema

  require Logger

  alias MoodleNetWeb.GraphQL.SchemaUtils
  alias MoodleNetWeb.GraphQL.Middleware.CollapseErrors
  alias Absinthe.Middleware.{Async, Batch}

  # @pipeline_modifier OverridePhase

  def plugins, do: [Async, Batch]

  def middleware(middleware, _field, _object) do
    # [{MoodleNetWeb.GraphQL.Middleware.Debug, :start}] ++
    middleware ++ [CollapseErrors]
  end

  import_types(MoodleNetWeb.GraphQL.AccessSchema)
  import_types(MoodleNetWeb.GraphQL.ActivitiesSchema)
  import_types(MoodleNetWeb.GraphQL.AdminSchema)
  import_types(MoodleNetWeb.GraphQL.BlocksSchema)
  import_types(MoodleNetWeb.GraphQL.CollectionsSchema)
  import_types(MoodleNetWeb.GraphQL.CommentsSchema)
  import_types(MoodleNetWeb.GraphQL.CommonSchema)
  import_types(MoodleNetWeb.GraphQL.CommunitiesSchema)
  import_types(MoodleNetWeb.GraphQL.Cursor)
  import_types(MoodleNetWeb.GraphQL.FeaturesSchema)
  import_types(MoodleNetWeb.GraphQL.FlagsSchema)
  import_types(MoodleNetWeb.GraphQL.FollowsSchema)
  import_types(MoodleNetWeb.GraphQL.InstanceSchema)
  import_types(MoodleNetWeb.GraphQL.JSON)
  import_types(MoodleNetWeb.GraphQL.LikesSchema)
  import_types(MoodleNetWeb.GraphQL.MiscSchema)
  import_types(MoodleNetWeb.GraphQL.ResourcesSchema)
  import_types(MoodleNetWeb.GraphQL.ThreadsSchema)
  import_types(MoodleNetWeb.GraphQL.UsersSchema)
  import_types(MoodleNetWeb.GraphQL.UploadSchema)

  # Extension Modules
  import_types(CommonsPub.Profile.GraphQL.Schema)
  import_types(CommonsPub.Character.GraphQL.Schema)
  import_types(Organisation.GraphQL.Schema)
  import_types(CommonsPub.Locales.GraphQL.Schema)
  import_types(CommonsPub.Tag.GraphQL.TagSchema)
  import_types(Taxonomy.GraphQL.TaxonomySchema)
  import_types(Measurement.Unit.GraphQL)
  import_types(Geolocation.GraphQL)

  import_types(ValueFlows.Schema)

  query do
    import_fields(:access_queries)
    import_fields(:activities_queries)
    import_fields(:blocks_queries)
    import_fields(:collections_queries)
    import_fields(:comments_queries)
    import_fields(:common_queries)
    import_fields(:communities_queries)
    import_fields(:features_queries)
    import_fields(:flags_queries)
    import_fields(:follows_queries)
    import_fields(:instance_queries)
    import_fields(:likes_queries)
    import_fields(:resources_queries)
    import_fields(:threads_queries)
    import_fields(:users_queries)

    # Extension Modules
    import_fields(:profile_queries)
    import_fields(:character_queries)
    import_fields(:circles_queries)
    import_fields(:tag_queries)

    # Taxonomy
    import_fields(:locales_queries)
    import_fields(:taxonomy_queries)

    # ValueFlows
    import_fields(:measurement_query)
    import_fields(:geolocation_query)
    import_fields(:value_flows_query)
    import_fields(:value_flows_extra_queries)
  end

  mutation do
    import_fields(:access_mutations)
    import_fields(:admin_mutations)
    import_fields(:blocks_mutations)
    import_fields(:collections_mutations)
    import_fields(:comments_mutations)
    import_fields(:common_mutations)
    import_fields(:communities_mutations)
    import_fields(:features_mutations)
    import_fields(:flags_mutations)
    import_fields(:follows_mutations)
    import_fields(:likes_mutations)
    import_fields(:resources_mutations)
    import_fields(:threads_mutations)
    import_fields(:users_mutations)

    # Extension Modules
    import_fields(:profile_mutations)
    import_fields(:character_mutations)
    import_fields(:circles_mutations)
    import_fields(:tag_mutations)
    import_fields(:taxonomy_mutations)
    # ValueFlows
    import_fields(:geolocation_mutation)
    import_fields(:measurement_mutation)

    import_fields(:value_flows_mutation)

    @desc "Fetch metadata from webpage"
    field :fetch_web_metadata, :web_metadata do
      arg(:url, non_null(:string))
      resolve(&MoodleNetWeb.GraphQL.MiscSchema.fetch_web_metadata/2)
    end

    # for debugging purposes only:
    # @desc "Fetch an AS2 object from URL"
    # field :fetch_object, type: :fetched_object do
    #   arg :url, non_null(:string)
    #   resolve &MoodleNetWeb.GraphQL.MiscSchema.fetch_object/2
    # end
  end

  @doc """
  hydrate SDL schema with resolvers
  """
  def hydrate(%Absinthe.Blueprint{}, _) do
    SchemaUtils.hydrations_merge([
      &Geolocation.GraphQL.Hydration.hydrate/0,
      &Measurement.Hydration.hydrate/0,
      &ValueFlows.Hydration.hydrate/0
    ])
  end

  # hydrations fallback
  def hydrate(_node, _ancestors) do
    []
  end

  union :any_context do
    description("Any type of known object")

    # TODO: autogenerate

    # types(SchemaUtils.context_types)

    types([
      :community,
      :collection,
      :resource,
      :comment,
      :flag,
      :follow,
      :like,
      :user,
      :organisation,
      :category,
      :taggable,
      :spatial_thing,
      :intent
    ])

    resolve_type(fn
      %MoodleNet.Users.User{}, _ -> :user
      %MoodleNet.Communities.Community{}, _ -> :community
      %MoodleNet.Collections.Collection{}, _ -> :collection
      %MoodleNet.Resources.Resource{}, _ -> :resource
      %MoodleNet.Threads.Thread{}, _ -> :thread
      %MoodleNet.Threads.Comment{}, _ -> :comment
      %MoodleNet.Follows.Follow{}, _ -> :follow
      %MoodleNet.Likes.Like{}, _ -> :like
      %MoodleNet.Flags.Flag{}, _ -> :flag
      %MoodleNet.Features.Feature{}, _ -> :feature
      %Organisation{}, _ -> :organisation
      %Geolocation{}, _ -> :spatial_thing
      %CommonsPub.Tag.Category{}, _ -> :category
      %CommonsPub.Tag.Taggable{}, _ -> :taggable
      # %ValueFlows.Agent.Agents{}, _ -> :agent
      # %ValueFlows.Agent.People{}, _ -> :person
      # %ValueFlows.Agent.Organizations{}, _ -> :organization
      %ValueFlows.Planning.Intent{}, _ -> :intent
      o, _ -> IO.inspect(any_context_resolve_unknown_type: o)
    end)
  end
end
