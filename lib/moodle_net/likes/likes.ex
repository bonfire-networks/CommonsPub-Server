defmodule MoodleNet.Likes do

  alias MoodleNet.Repo
  alias MoodleNet.Likes.{AlreadyLikedError, Like, NotLikeableError}
  alias MoodleNet.Users.User
  import Ecto.Query
  alias Ecto.Changeset

  def data(ctx) do
    Dataloader.Ecto.new Repo,
      query: &query/2,
      default_params: %{ctx: ctx}
  end

  def query(q, %{ctx: _}), do: q

  def fetch(id), do: Repo.single(fetch_q(id))

  defp fetch_q(id) do
    from(l in Like,
      where: is_nil(l.deleted_at),
      where: not is_nil(l.published_at),
      where: l.id == ^id)
  end

  def find(%User{} = liker, liked), do: Repo.single(find_q(liker.id, liked.id))

  defp find_q(liker_id, liked_id) do
    from(l in Like,
      where: l.creator_id == ^liker_id,
      where: l.context_id == ^liked_id,
      where: is_nil(l.deleted_at)
    )
  end

  def insert(%User{} = liker, liked, fields) do
    Repo.insert(Like.create_changeset(liker, liked, fields))
  end

  defp publish(%Like{} = like, verb) do
    # MoodleNet.FeedPublisher.publish(%{
    #   "verb" => verb,
    #   "creator_id" => like.creator_id,
    #   "context_id" => like.id
    # })
    :ok
  end

  @doc """
  NOTE: assumes liked participates in meta, otherwise gives constraint error changeset
  """
  def create(%User{} = liker, liked, fields) do
    Repo.transact_with(fn ->
      case find(liker, liked) do
        {:ok, _} ->
          {:error, AlreadyLikedError.new("user")}

        _ ->
          with {:ok, like} <- insert(liker, liked, fields),
               :ok <- publish(like, "create") do
            {:ok, like}
          end
      end
    end)
  end

  def update(%Like{} = like, fields) do
    Repo.update(Like.update_changeset(like, fields))
  end

  @doc """
  Return a list of likes for a user.
  """
  def list_by(%User{} = user), do: Repo.all(list_by_query(user))

  @doc """
  Return a list of likes for any object participating in the meta abstraction.
  """
  def list_of(%{id: _id} = thing), do: Repo.all(list_of_query(thing))

  defp list_by_query(%User{id: id}) do
    from(l in Like,
      where: is_nil(l.deleted_at),
      where: l.creator_id == ^id
    )
  end

  defp list_of_query(%{id: id}) do
    from(l in Like,
      where: is_nil(l.deleted_at),
      where: l.context_id == ^id
    )
  end

end
