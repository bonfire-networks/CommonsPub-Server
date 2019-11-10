# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.Schema do
  @moduledoc "Root GraphQL Schema"
  use Absinthe.Schema
  alias MoodleNetWeb.GraphQL.{
    ActivitiesSchema,
    CollectionsSchema,
    CommentsSchema,
    CommonSchema,
    CommunitiesSchema,
    LocalisationSchema,
    MiscSchema,
    MoodleverseSchema,
    ResourcesSchema,
    UsersSchema,
  }

  import_types ActivitiesSchema
  import_types CollectionsSchema
  import_types CommentsSchema
  import_types CommonSchema
  import_types CommunitiesSchema
  import_types InstanceSchema
  import_types LocalisationSchema
  import_types MiscSchema
  import_types MoodleverseSchema
  import_types ResourcesSchema
  import_types UsersSchema

  query do
    import_fields :collections_queries
    import_fields :comments_queries
    import_fields :communities_queries
    import_fields :instance_queries
    import_fields :localisation_queries
    import_fields :moodleverse_queries
    import_fields :resources_queries
    import_fields :users_queries
  end

  mutation do
    import_fields :collections_mutations
    import_fields :comments_mutations
    import_fields :common_mutations
    import_fields :communities_mutations
    import_fields :resources_mutations
    import_fields :users_mutations

    @desc "Fetch metadata from webpage"
    field :fetch_web_metadata, type: :web_metadata do
      arg :url, non_null(:string)
      resolve &MiscSchema.fetch_web_metadata/2
    end

    @desc "Fetch an AS2 object from URL"
    field :fetch_object, type: :fetched_object do
      arg :url, non_null(:string)
      resolve &MiscSchema.fetch_object/2
    end
  end

end
