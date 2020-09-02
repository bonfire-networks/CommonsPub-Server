# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Web.LayoutView do
  use CommonsPub.Web, :view

  import CommonsPub.Web.Helpers.Common

  def app_name(), do: CommonsPub.Config.get(:app_name)
end
