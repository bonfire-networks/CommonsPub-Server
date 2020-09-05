# SPDX-License-Identifier: AGPL-3.0-only
Absinthe.Test.prime(CommonsPub.Web.GraphQL.Schema)
{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(CommonsPub.Repo, :manual)
ExUnit.configure(exclude: :external)
