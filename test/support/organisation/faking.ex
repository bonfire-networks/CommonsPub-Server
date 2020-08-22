# SPDX-License-Identifier: AGPL-3.0-only
defmodule Organisation.Test.Faking do
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  alias CommonsPub.Utils.Simulation

  alias Organisation
  import Organisation.Simulate

  def assert_organisation(%Organisation{} = org) do
    assert_organisation(Map.from_struct(org))
  end

  def assert_organisation(org) do
    assert_object(org, :assert_organisation, id: &assert_ulid/1)
    #  character.name: &assert_binary/1,
    #  character.updated_at: assert_optional(&assert_datetime/1),
    #  disabled_at: assert_optional(&assert_datetime/1),
  end

  def organisation_fields(extra \\ []) do
    extra ++ ~w(id name summary __typename)a
  end

  def organisation_query(options \\ []) do
    gen_query(:organisation_id, &organisation_subquery/1, options)
  end

  def organisation_subquery(options \\ []) do
    gen_subquery(:organisation_id, :organisation, &organisation_fields/1, options)
  end
end
