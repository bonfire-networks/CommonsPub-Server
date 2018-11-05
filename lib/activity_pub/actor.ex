defmodule ActivityPub.Actor do
  use Ecto.Schema

  schema "activity_pub_actors" do
    field(:uri, :string)
    field(:nickname, :string)
    field(:local, :boolean, default: true)
    field(:bio, :string)
    field(:avatar, :map)
    field(:info, :map, default: %{})
    field(:type, {:array, :string}, default: [])
    field(:openness, :string)
    field(:follower_address, :string)

    timestamps()
  end

  def avatar_url(user) do
    case user.avatar do
      %{"url" => [%{"href" => href} | _]} -> href
      _ -> "#{MoodleNetWeb.base_url()}/images/avi.png"
    end
  end

  def banner_url(user) do
    case user.info["banner"] do
      %{"url" => [%{"href" => href} | _]} -> href
      _ -> "#{MoodleNetWeb.base_url()}/images/banner.png"
    end
  end
end
