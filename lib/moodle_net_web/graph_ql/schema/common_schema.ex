# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.CommonSchema do
  use Absinthe.Schema.Notation

  interface :node do
    field(:id, non_null(:id))
    field(:type, non_null(list_of(non_null(:string))))
    field(:name, :string)
  end

  object :page_info do
    field(:start_cursor, :integer)
    field(:end_cursor, :integer)
  end
end
