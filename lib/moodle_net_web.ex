defmodule MoodleNetWeb do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use MoodleNetWeb, :controller
      use MoodleNetWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: MoodleNetWeb
      import Plug.Conn
      import MoodleNetWeb.{Gettext, Router.Helpers}
      alias MoodleNetWeb.Router.Helpers, as: Routes
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

      # Remove imports
      import MoodleNetWeb.{ErrorHelpers, Gettext, Router.Helpers}
      import Phoenix.HTML.Form
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
    MoodleNetWeb.Endpoint.url()
  end
end
