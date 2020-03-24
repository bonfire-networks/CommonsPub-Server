# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.Schema do
  @moduledoc "Root GraphQL Schema"
  use Absinthe.Schema
  alias MoodleNetWeb.GraphQL.{
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
    UploadSchema,
  }

  # require Logger

  alias MoodleNetWeb.GraphQL.Middleware.CollapseErrors
  alias Absinthe.Middleware.Batch

  # @pipeline_modifier OverridePhase

  def plugins, do: [Batch]

  def middleware(middleware, _field, _object) do
    # [{MoodleNetWeb.GraphQL.Middleware.Debug, :start}] ++
    middleware ++ [CollapseErrors]
  end

  import_types ActivitiesSchema
  import_types AdminSchema
  import_types BlocksSchema
  import_types CollectionsSchema
  import_types CommentsSchema
  import_types CommonSchema
  import_types CommunitiesSchema
  import_types Cursor
  import_types FeaturesSchema
  import_types FlagsSchema
  import_types FollowsSchema
  import_types InstanceSchema
  import_types JSON
  import_types LikesSchema
  # import_types LocalisationSchema
  import_types MiscSchema
  import_types MoodleverseSchema
  import_types ResourcesSchema
  import_types ThreadsSchema
  import_types UsersSchema
  import_types UploadSchema

  # optional modules:
  import_types Taxonomy.GraphQL.LocalesSchema
  import_types Taxonomy.GraphQL.TagsSchema
  import_types ValueFlows.GraphQL.Util
  import_types ValueFlows.GraphQL.Measurement
  import_types ValueFlows.GraphQL.Geolocation
  import_types ValueFlows.GraphQL.Agent
  import_types ValueFlows.GraphQL.Planning

  query do
    import_fields :activities_queries
    import_fields :blocks_queries
    import_fields :collections_queries
    import_fields :comments_queries
    import_fields :common_queries
    import_fields :communities_queries
    import_fields :features_queries
    import_fields :flags_queries
    import_fields :follows_queries
    import_fields :instance_queries
    import_fields :likes_queries
    # import_fields :localisation_queries
    import_fields :moodleverse_queries
    import_fields :resources_queries
    import_fields :threads_queries
    import_fields :users_queries

    # Taxonomy
    import_fields :locales_queries
    import_fields :tags_queries
    import_fields :tags_queries

    # ValueFlows
    import_fields :measurement_query
    import_fields :geolocation_query
    # import_fields :agent_query
    # import_fields :planning_query
  end

  mutation do
    import_fields :admin_mutations
    import_fields :blocks_mutations
    import_fields :collections_mutations
    import_fields :comments_mutations
    import_fields :common_mutations
    import_fields :communities_mutations
    import_fields :features_mutations
    import_fields :flags_mutations
    import_fields :follows_mutations
    import_fields :likes_mutations
    import_fields :resources_mutations
    import_fields :threads_mutations
    import_fields :users_mutations
    import_fields :upload_mutations

    # ValueFlows
    import_fields :measurement_mutation
    import_fields :geolocation_mutation
    # import_fields :agent_mutation
    # import_fields :planning_mutation

    @desc "Fetch metadata from webpage"
    field :fetch_web_metadata, :web_metadata do
      arg :url, non_null(:string)
      resolve &MiscSchema.fetch_web_metadata/2
    end

  #   @desc "Fetch an AS2 object from URL"
  #   field :fetch_object, type: :fetched_object do
  #     arg :url, non_null(:string)
  #     resolve &MiscSchema.fetch_object/2
  #   end

  end

end
