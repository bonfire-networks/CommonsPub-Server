defmodule MoodleNet.ActivityPubMock do
  @behaviour ActivityPub.Adapter
  import Ecto.Query

  def get_actor_by_ap_id(ap_id) do
    actor = ActivityPub.get_by_id(ap_id, aspect: :actor)
    {:ok, actor}
  end

  def get_actor_by_username(username) do
    try do
      query =
        from(
          object in ActivityPub.Object,
          where: fragment("? ->> 'preferredUsername' = ?", object.data, ^username)
        )

      actor = MoodleNet.Repo.one(query)

      actor = %{
        preferred_username: actor.data["preferredUsername"],
        id: actor.data["id"],
        name: actor.data["name"] || "",
        summary: actor.data["summary"] || "",
        icon: actor.data["icon"] || "",
        image: actor.data["image"] || "",
        signing_key: nil
      }

      {:ok, actor}
    rescue
      UndefinedFunctionError -> {:error, nil}
    end
  end

  def handle_activity(_activity) do
    :ok
  end
end
