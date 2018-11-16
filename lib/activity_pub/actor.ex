defmodule ActivityPub.Actor do
  use Ecto.Schema

  alias ActivityPub.Follow

  schema "activity_pub_actors" do
    field(:type, {:array, :string}, default: [])
    field(:uri, :string)
    field(:name, :string)
    field(:summary, :string)
    field(:preferred_username, :string)
    field(:avatar, :map)
    field(:info, :map, default: %{})

    field(:local, :boolean, default: true)
    field(:openness, :string)

    field(:inbox_uri, :string)
    field(:outbox_uri, :string)
    field(:following_uri, :string)
    field(:followers_uri, :string)
    field(:liked_uri, :string)
    field(:streams, :map, default: %{})

    field(:shared_inbox_uri, :string)
    field(:proxy_url, :string)

    timestamps()

    field(:followers_count, :integer, default: 0)
    field(:following_count, :integer, default: 0)

    many_to_many(:followers, Follow,
      join_through: ActivityPub.Follow,
      join_keys: [following_id: :id, follower_id: :id]
    )

    many_to_many(:followings, Follow,
      join_through: ActivityPub.Follow,
      join_keys: [follower_id: :id, following_id: :id]
    )
  end

  def create_local_changeset(params) do
    import Ecto.Changeset

    %__MODULE__{}
    |> cast(params, [:name, :preferred_username])
    |> change(local: true, type: ["Person"])
  end

  def set_uris(%__MODULE__{id: id} = actor) do
    uris = ActivityPub.UrlBuilder.actor_uris(actor)

    Ecto.Changeset.change(actor, uris)
  end

  def avatar_url(user) do
    case user.avatar do
      %{"url" => [%{"href" => href} | _]} -> href
      _ -> "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y"
      # _ -> "#{MoodleNetWeb.base_url()}/images/avi.png"
    end
  end

  # def banner_url(user) do
  #   case user.info["banner"] do
  #     %{"url" => [%{"href" => href} | _]} -> href
  #     _ -> "#{MoodleNetWeb.base_url()}/images/banner.png"
  #   end
  # end
end
