# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.AdminSchema do
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver
  alias MoodleNetWeb.GraphQL.AdminResolver

  object :admin_queries do
    @desc "Admin is a virtual object for the administration panel"
    field :admin, :admin
  end

  object :admin_mutations do
    
    @desc "Close a flag"
    field :close_flag, type: :boolean do
      arg(:id, non_null(:integer))
      resolve(&AdminResolver.close_flag/2)
    end

  end

  object :admin do
    field :flagged_collections, type: list_of(:flagged_collection) do
      arg(:open, :boolean)
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(&AdminResolver.flagged_collections/2)
    end
    field :flagged_resources, type: list_of(:flagged_resource) do
      arg(:open, :boolean)
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(&AdminResolver.flagged_resources/2)
    end
    field :flagged_comments, type: list_of(:flagged_comment) do
      arg(:open, :boolean)
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(&AdminResolver.flagged_comments/2)
    end
    
  end

  object :flagged_collection do
    field(:id, :integer)
    field(:collection_id, :integer)
    field(:reporter_id, :integer)
    field(:reason, :string)
    field(:open, :boolean)
  end

  object :flagged_resource do
    field(:id, :integer)
    field(:resource_id, :integer)
    field(:reporter_id, :integer)
    field(:reason, :string)
    field(:open, :boolean)
  end

  object :flagged_comment do
    field(:id, :integer)
    field(:comment_id, :integer)
    field(:reporter_id, :integer)
    field(:reason, :string)
    field(:open, :boolean)
  end

end
