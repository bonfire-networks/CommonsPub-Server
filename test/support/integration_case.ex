# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use MoodleNetWeb.ConnCase
      use PhoenixIntegration
    end
  end
end
