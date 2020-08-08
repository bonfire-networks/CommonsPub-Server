defmodule MoodleNetWeb.My.SettingsUpload do
  use MoodleNetWeb, :controller

  # params we receive:
  # %{
  #   "_csrf_token" => "yHxqH5EG6NtAe0B433A3njID",
  #   "profile" => %{
  #     "email" => "test@jfdgkjdf.space",
  #     "icon" => %Plug.Upload{
  #       content_type: "image/png",
  #       filename: "fist.png",
  #       path: "/tmp/plug-1595/multipart-1595441441-553343146418336-1"
  #     },
  #     "location" => "",
  #     "name" => "namie",
  #     "summary" => "yay"
  #   },
  # }

  def upload(%{assigns: %{current_user: current_user}} = conn, params) do
    attrs = MoodleNetWeb.Helpers.Common.input_to_atoms(params)

    # maybe_upload(params["profile"]["icon"], "icon")
    # maybe_upload(params["profile"]["image"], "image")

    {:ok, _edit_profile} =
      MoodleNetWeb.GraphQL.UsersResolver.update_profile(attrs, %{
        context: %{current_user: current_user}
      })

    conn
    |> redirect(external: "/~/profile")
  end

  defp maybe_upload(%Plug.Upload{} = file, field) do
    IO.inspect(file: file)
  end

  defp maybe_upload(_, _) do
    nil
  end
end