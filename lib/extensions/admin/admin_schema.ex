# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Web.GraphQL.AdminSchema do
  use Absinthe.Schema.Notation
  alias CommonsPub.Web.GraphQL.AdminResolver

  object :admin_queries do
    @desc "Admin is a virtual object for the administration panel"
    field :admin, :admin do
      resolve(&AdminResolver.admin/2)
    end
  end

  object :admin_mutations do
    @desc "Close a flag"
    field :resolve_flag, :flag do
      arg(:flag_id, non_null(:string))
      resolve(&AdminResolver.resolve_flag/2)
    end

    @desc "Sends an email invite, and adds the email to invite list for private instances"
    field :send_invite, :boolean do
      arg(:email, non_null(:string))
      resolve(&AdminResolver.send_invite/2)
    end

    @desc "Deactivate a remote user, blocking further activities from it"
    field :deactivate_user, :user do
      arg(:id, non_null(:string))
      resolve(&AdminResolver.deactivate_user/2)
    end
  end

  object :admin do
  end
end
