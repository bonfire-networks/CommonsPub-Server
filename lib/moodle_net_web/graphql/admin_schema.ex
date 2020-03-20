# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.AdminSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.AdminResolver

  object :admin_queries do

    @desc "Admin is a virtual object for the administration panel"
    field :admin, :admin do
      resolve &AdminResolver.admin/2
    end

  end

  object :admin_mutations do
    
    @desc "Close a flag"
    field :resolve_flag, :flag do
      arg :flag_id, non_null(:string)
      resolve &AdminResolver.resolve_flag/2
    end

  end

  object :admin do
    
  end

end
