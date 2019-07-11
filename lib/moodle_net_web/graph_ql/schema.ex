# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.Schema do
  @moduledoc """

  GraphQL client API

  ## Challenges

  The initial plan was to create a [generic GraphQL API in ActivityPub style, which would then be extended with queries/fields specific to MoodleNet](https://gitlab.com/CommonsPub/commonspub.gitlab.io/tree/master/graphql). (Alex however found this plan [too difficult](https://hackmd.io/GRkqbk9TS6aWXF_hz17zyw#)). _(NB: with the upcoming [support for SDL and complete rewrite of schema internals in Absinthe 1.5](https://github.com/absinthe-graphql/absinthe/blob/master/CHANGELOG.md) (GraphQL lib for Elixir), this may soon be easier.)_

  So we just have a GraphQL client API specific to MoodleNet. Which means instead of using _Note_ like in ActivityStreams, we have `Comments`, etc.

  ### TODO - Refactoring

  The GraphQL code works, but the code it is not uniform. Alex started refactoring, but it is not finished. Most of this work was just creating new modules and moving functions from one to another. Maybe worth refactoring when we upgrade to Absinthe 1.5?


  ### FIXME - too many queries

  If we look at AppSignal we can see that most of the GraphQL requests currently used in the MoodleNet front-end result in many requests, even up to more than 100: [https://appsignal.com/moodlenet/sites/5cb0a54f14ad6644eb4d6b4d/performance/incidents/1](https://appsignal.com/moodlenet/sites/5cb0a54f14ad6644eb4d6b4d/performance/incidents/1)

  There are three main reasons:

  1. Pagination and batch load incompatibility
  2. Big GraphQL queries
  3. Complexity of the database with many joins to load an object

  Currently, the database is small enough for this not to be a problem. However, once moian instance grows and the database gets bigger, requests will be slower and take too much time.


  ## Entrypoint

  The initial point of entry is `MoodleNetWeb.GraphQL.Schema`, which is mounted in the `MoodleNetWeb.Router`, not before using the `MoodleNetWeb.Router.graphql/2` plug in the pipeline to load the user into the `MoodleNetWeb.GraphQL.Context`.


  ## Schemas

  The initial schema uses specific schemas — defining fields and relations — per `ActivityPub.Entity` type: [moodle_net_web/graph_ql/schema](https://gitlab.com/moodlenet/servers/federated/tree/develop/lib/moodle_net_web/graph_ql/schema)

  (TODO: _Comment_ schema is not split up correctly.)


  ## Resolvers

  The resolvers are functions to load records for each query type. Again there is one per `ActivityPub.Entity` type: [moodle_net_web/graph_ql/resolvers](https://gitlab.com/moodlenet/servers/federated/tree/develop/lib/moodle_net_web/graph_ql/resolvers) (TODO: _Comment, Activity_, etc. are done but need to be split in better modules.)

  The resolvers use some common functions defined in `MoodleNetWeb.GraphQL.MoodleNetSchema`.


  ## Pagination

  There isn't one standard pagination method for GraphQL. We use the complete connection model from the [GraphQL pagination documentation](https://graphql.org/learn/pagination/).

  The cursor is just an ID. This is connected to `ActivityPub.SQL.Paginate`.


  ## Associations

  Many associations are resolved using `MoodleNetWeb.GraphQL.MoodleNetSchema.with_connection/1`, see for example `:joined_communities` in `MoodleNetWeb.GraphQL.UserSchema`. *FIXME - This function has an 1+n query problem.*

  There is also `MoodleNetWeb.GraphQL.MoodleNetSchema.with_assoc/2` which was created before `MoodleNetWeb.GraphQL.MoodleNetSchema.with_connection/1`. It supports “single” and “many” associations. It also used the [batch API](https://hexdocs.pm/absinthe/Absinthe.Middleware.Batch.html). This middleware avoids the 1+n query problem. But unfortunately it does not seem to play well with pagination.

  """

  use Absinthe.Schema

  alias MoodleNetWeb.GraphQL.{
    MoodleNetSchema,
    MiscSchema,
    CommonSchema,
    UserSchema,
    CommunitySchema,
    CollectionSchema,
    ResourceSchema,
    CommentSchema,
    ActivitySchema
  }

  import_types(UserSchema)
  import_types(CommentSchema)
  import_types(CommunitySchema)
  import_types(CollectionSchema)
  import_types(ResourceSchema)
  import_types(ActivitySchema)
  import_types(MiscSchema)
  import_types(CommonSchema)

  query do
    import_fields(:user_queries)
    import_fields(:comment_queries)
    import_fields(:community_queries)
    import_fields(:collection_queries)
    import_fields(:resource_queries)

    @desc "Get local activity list"
    field :local_activities, type: non_null(:generic_activity_page) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(&ActivitySchema.local_activity_list/2)
    end

  end

  mutation do
    import_fields(:user_mutations)
    import_fields(:comment_mutations)
    import_fields(:community_mutations)
    import_fields(:collection_mutations)
    import_fields(:resource_mutations)

    @desc "Fetch metadata from webpage"
    field :fetch_web_metadata, type: :web_metadata do
      arg(:url, non_null(:string))
      resolve(&MiscSchema.fetch_web_metadata/2)
    end
  end

end
