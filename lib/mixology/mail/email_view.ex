# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.EmailView do
  @moduledoc """
  Email view
  """
  use MoodleNetWeb, :view

  def app_name(), do: Application.get_env(:moodle_net, :app_name)
end
