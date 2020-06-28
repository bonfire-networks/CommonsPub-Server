defmodule MoodleNetWeb.Helpers.Profiles do
  alias MoodleNet.{
    Repo
  }

  def prepare(profile) do
    profile = Repo.preload(profile, :actor)
    profile = Repo.preload(profile, :icon)
    icon = Repo.preload(profile.icon, :content_upload)

    icon =
      if(!is_nil(icon) and !is_nil(icon.content_upload) and !is_nil(icon.content_upload.url)) do
        icon.content_upload.url
      else
        icon = Repo.preload(profile.icon, :content_mirror)

        if(!is_nil(icon) and !is_nil(icon.content_mirror) and !is_nil(icon.content_mirror.url)) do
          icon.content_mirror.url
        else
          # TODO: replace with email
          MoodleNet.Users.Gravatar.url(profile.id)
        end
      end

    profile
    |> Map.merge(%{icon: icon})
  end
end
