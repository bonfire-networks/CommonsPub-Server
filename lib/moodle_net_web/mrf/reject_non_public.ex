defmodule ActivityPubWeb.MRF.RejectNonPublic do
  @behaviour ActivityPubWeb.MRF

  @mrf_rejectnonpublic Application.get_env(:moodle_net, :mrf_rejectnonpublic)
  @allow_followersonly Keyword.get(@mrf_rejectnonpublic, :allow_followersonly, true)
  @allow_direct Keyword.get(@mrf_rejectnonpublic, :allow_direct, true)

  @impl true
  def filter(%{"type" => "Create"} = object) do
    # FIXME
    user = nil
    # user = User.get_cached_by_ap_id(object["actor"])
    public = "https://www.w3.org/ns/activitystreams#Public"

    # Determine visibility
    visibility =
      cond do
        public in object["to"] -> "public"
        public in object["cc"] -> "unlisted"
        user.follower_address in object["to"] -> "followers"
        true -> "direct"
      end

    case visibility do
      "public" ->
        {:ok, object}

      "unlisted" ->
        {:ok, object}

      "followers" ->
        if @allow_followersonly do
          {:ok, object}
        else
          {:reject, nil}
        end

      "direct" ->
        if @allow_direct do
          {:ok, object}
        else
          {:reject, nil}
        end
    end
  end

  @impl true
  def filter(object), do: {:ok, object}
end
