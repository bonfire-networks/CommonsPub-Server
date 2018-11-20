defmodule ActivityPub.Follow do
  # use Ecto.Schema

  # alias ActivityPub.Actor

  # schema "activity_pub_follows" do
  #   belongs_to(:follower, Actor)
  #   belongs_to(:following, Actor)

  #   timestamps(updated_at: false)
  # end

  # def create_changeset(%Actor{} = follower, %Actor{} = following) do
  #   %__MODULE__{}
  #   |> Ecto.Changeset.change()
  #   |> Ecto.Changeset.put_assoc(:follower, follower)
  #   |> Ecto.Changeset.put_assoc(:following, following)
  #   |> common_create_changeset()
  # end

  # def create_changeset(follower_id, following_id)
  #     when is_integer(follower_id) and is_integer(following_id) do
  #   %__MODULE__{}
  #   |> Ecto.Changeset.change(follower_id: follower_id, following_id: following_id)
  #   |> common_create_changeset()
  # end

  # defp common_create_changeset(ch) do
  #   ch
  #   |> Ecto.Changeset.foreign_key_constraint(:follower_id)
  #   |> Ecto.Changeset.foreign_key_constraint(:following_id)
  #   |> Ecto.Changeset.unique_constraint(:follower_id, name: "activity_pub_follows_unique_index")
  # end

  # def delete_query(%Actor{id: follower_id}, %Actor{id: following_id}) do
  #   delete_query(follower_id, following_id)
  # end

  # def delete_query(follower_id, following_id)
  #     when is_integer(follower_id) and is_integer(following_id) do
  #   import Ecto.Query, only: [from: 2]

  #   from(f in ActivityPub.Follow,
  #     where: f.follower_id == ^follower_id and f.following_id == ^following_id
  #   )
  # end
end
