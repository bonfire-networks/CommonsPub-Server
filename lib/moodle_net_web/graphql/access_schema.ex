# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.AccessSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{AccessResolver, CommonResolver}

  object :access_queries do

    field :register_email_accesses, list_of(:string) do
      resolve &AccessResolver.register_email_accesses/2
    end

    field :register_email_domain_accesses, list_of(:string) do
      resolve &AccessResolver.register_email_domain_accesses/2
    end

  end

  object :access_mutations do
    
    field :create_register_email_access, :boolean do
      arg :email, non_null(:string)
      resolve &AccessResolver.create_register_email_access/2
    end

    field :create_register_email_domain_access, :boolean do
      arg :domain, non_null(:string)
      resolve &AccessResolver.create_register_email_domain_access/2
    end

  end

  object :register_email_access do
    field :id, non_null(:string)
    field :email, non_null(:string)
    field :created_at, non_null(:string) do
      resolve &CommonResolver.created_at_edge/3
    end
    field :updated_at, non_null(:string)
  end

  object :register_email_domain_access do
    field :id, non_null(:string)
    field :domain, non_null(:string)
    field :created_at, non_null(:string) do
      resolve &CommonResolver.created_at_edge/3
    end
    field :updated_at, non_null(:string)
  end

end
