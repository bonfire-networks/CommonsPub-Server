# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb do
  @moduledoc """
  Entrypoint for defining the MoodleNet web interfaces, such as controllers, views, channels and so on.

  The definitions below will be executed for every view, controller, etc, so keep them short and clean, focused on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions below. Instead, define any helper function in modules and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: MoodleNetWeb
      import Plug.Conn
      import MoodleNetWeb.{Gettext, Router.Helpers}
      alias MoodleNetWeb.Router.Helpers, as: Routes
      alias ActivityPubWeb.Router.Helpers, as: APRoutes
      alias MoodleNetWeb.Plugs.ScrubParams

      action_fallback(MoodleNetWeb.FallbackController)
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/moodle_net_web/",
        path: Phoenix.Template.module_to_template_root(__MODULE__, MoodleNetWeb, "View") <> "/templates/",
        pattern: "*",
        namespace: MoodleNetWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      import MoodleNetWeb.ErrorHelpers
      import MoodleNetWeb.Gettext

      use Phoenix.HTML

      alias MoodleNetWeb.Router.Helpers, as: Routes
      alias ActivityPubWeb.Router.Helpers, as: APRoutes

      alias MoodleNet.Accounts.User
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import MoodleNetWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def base_url do
    Application.get_env(:moodle_net, :base_url) || MoodleNetWeb.Endpoint.url()
  end
end
