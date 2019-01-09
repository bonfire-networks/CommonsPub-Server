defmodule MoodleNetWeb.LayoutView do
  use MoodleNetWeb, :view

  defp logo_url() do
    path = MoodleNetWeb.Endpoint.static_path("/images/moodlenet-logo.png")

    MoodleNetWeb.Endpoint.struct_url()
    |> Map.put(:path, path)
    |> URI.to_string()
  end
end
