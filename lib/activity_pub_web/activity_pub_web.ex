# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb do
  @moduledoc """
  Entrypoint for defining the ActivityPub web interfaces, such as the REST API for server-to-server federation.

  The definitions below will be executed for every view, controller, etc, so keep them short and clean, focused on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions below. Instead, define any helper function in modules and import those modules here.
  """

  def controller do
    quote do
      # Make this namespace configurable
      use Phoenix.Controller, namespace: MoodleNetWeb

      import Plug.Conn
      import ActivityPubWeb.Gettext
      alias MoodleNetWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/activity_pub_web/templates",
        namespace: ActivityPubWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ActivityPubWeb.ErrorHelpers
      import ActivityPubWeb.Gettext
      alias MoodleNetWeb.Router.Helpers, as: Routes
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
      import ActivityPubWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
