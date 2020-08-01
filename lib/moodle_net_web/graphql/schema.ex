# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.Schema do
  @moduledoc "Root GraphQL Schema"
  use Absinthe.Schema

  alias MoodleNetWeb.GraphQL.{
    AccessSchema,
    ActivitiesSchema,
    AdminSchema,
    BlocksSchema,
    CollectionsSchema,
    CommentsSchema,
    CommonSchema,
    CommunitiesSchema,
    Cursor,
    JSON,
    FeaturesSchema,
    FlagsSchema,
    FollowsSchema,
    InstanceSchema,
    LikesSchema,
    # LocalisationSchema,
    MiscSchema,
    MoodleverseSchema,
    ResourcesSchema,
    ThreadsSchema,
    UsersSchema,
    UploadSchema
  }

  require Logger

  alias MoodleNetWeb.GraphQL.Middleware.CollapseErrors
  alias Absinthe.Middleware.{Async, Batch}

  # @pipeline_modifier OverridePhase

  def plugins, do: [Async, Batch]

  def middleware(middleware, _field, _object) do
    # [{MoodleNetWeb.GraphQL.Middleware.Debug, :start}] ++
    middleware ++ [CollapseErrors]
  end

  import_types(AccessSchema)
  import_types(ActivitiesSchema)
  import_types(AdminSchema)
  import_types(BlocksSchema)
  import_types(CollectionsSchema)
  import_types(CommentsSchema)
  import_types(CommonSchema)
  import_types(CommunitiesSchema)
  import_types(Cursor)
  import_types(FeaturesSchema)
  import_types(FlagsSchema)
  import_types(FollowsSchema)
  import_types(InstanceSchema)
  import_types(JSON)
  import_types(LikesSchema)
  # import_types LocalisationSchema
  import_types(MiscSchema)
  import_types(MoodleverseSchema)
  import_types(ResourcesSchema)
  import_types(ThreadsSchema)
  import_types(UsersSchema)
  import_types(UploadSchema)

  # Extension Modules
  import_types(Profile.GraphQL.Schema)
  import_types(Character.GraphQL.Schema)
  import_types(Organisation.GraphQL.Schema)
  import_types(Locales.GraphQL.Schema)
  import_types(Tag.GraphQL.TagSchema)
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
    # import_fields :localisation_queries
    import_fields(:moodleverse_queries)
    import_fields(:resources_queries)
    import_fields(:threads_queries)
    import_fields(:users_queries)

    # Extension Modules
    import_fields(:profile_queries)
    import_fields(:character_queries)
    import_fields(:organisations_queries)
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
    import_fields(:organisations_mutations)
    import_fields(:tag_mutations)
    import_fields(:taxonomy_mutations)
    # ValueFlows
    import_fields(:geolocation_mutation)
    import_fields(:measurement_mutation)
    import_fields(:value_flows_mutation)

    @desc "Fetch metadata from webpage"
    field :fetch_web_metadata, :web_metadata do
      arg(:url, non_null(:string))
      resolve(&MiscSchema.fetch_web_metadata/2)
    end

    # for debugging purposes only:
    # @desc "Fetch an AS2 object from URL"
    # field :fetch_object, type: :fetched_object do
    #   arg :url, non_null(:string)
    #   resolve &MiscSchema.fetch_object/2
    # end
  end

  @doc """
  hydrate SDL schema with resolvers
  """
  def hydrate(%Absinthe.Blueprint{}, _) do
    hydrators = [
      &Geolocation.GraphQL.Hydration.hydrate/0,
      &Measurement.Hydration.hydrate/0,
      &ValueFlows.Hydration.hydrate/0
    ]

    Enum.reduce(hydrators, %{}, fn hydrate_fn, hydrated ->
      hydrate_merge(hydrated, hydrate_fn.())
    end)
  end

  # hydrations fallback
  def hydrate(_node, _ancestors) do
    []
  end

  defp hydrate_merge(a, b) do
    Map.merge(a, b, fn _, a, b -> Map.merge(a, b) end)
  end
end
