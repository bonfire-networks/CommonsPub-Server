defmodule MoodleNetWeb.My.TagMeiliLive do
  @moduledoc """
  Alternative approach to tagging, using JS to directly use Meili's API, rather than passing through Elixir
  """
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       meili_host: System.get_env("SEARCH_MEILI_INSTANCE", "http://localhost:7700"),
       tag_target: ""
     )}
  end
end
