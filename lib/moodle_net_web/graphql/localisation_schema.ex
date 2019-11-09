# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.LocalisationSchema do
  @moduledoc "GraphQL languages and countries"

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.LocalisationResolver

  object :localisation_queries do

    @desc "Get list of languages we know about"
    field :languages, list_of(:language) do
      resolve &LocalisationResolver.languages/2
    end

    @desc "Get list of languages we know about"
    field :countries, list_of(:country) do
      resolve &LocalisationResolver.countries/2
    end

  end

  object :language do
    @desc "2-letter ISO code"
    field :id, :string
    field :english_name, :string
    field :local_name, :string
  end

  object :country do
    @desc "2-letter ISO code"
    field :id, :string
    field :english_name, :string
    field :local_name, :string
  end

end
