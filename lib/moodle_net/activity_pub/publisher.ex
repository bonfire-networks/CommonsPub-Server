defmodule MoodleNet.ActivityPub.Publisher do
  alias ActivityPub.Actor
  alias MoodleNet.ActivityPub.Utils

  # FIXME: this will break if parent is an object that isn't in AP database or doesn't have a pointer_id filled
  def comment(comment) do
    with {:ok, parent} <- MoodleNet.Meta.follow(comment.thread.parent),
         parent_id <- Utils.get_parent_id(parent),
         {:ok, actor} <- ActivityPub.Actor.get_by_username(comment.creator.preferred_username),
         {to, cc} <- Utils.determine_recipients(actor, parent),
         object <- %{
           "content" => comment.current.content,
           "to" => to,
           "cc" => cc,
           "actor" => actor.ap_id,
           "attributedTo" => actor.ap_id
         },
         params <- %{
           actor: actor,
           to: to,
           object: object,
           context: parent_id,
           additional: %{
             "cc" => cc
           }
         } do
      #FIXME: pointer_id isn't getting inserted for whatever reason
      ActivityPub.create(params, comment.id)
    else
      _e -> :error
    end
  end

  ## FIXME: this is currently implemented in a spec non-conforming way, AP follows are supposed to be handshakes
  ## that are only reflected in the host database upon receiving an Accept activity in response. in this case
  ## the follow activity is created based on a Follow object that's already in MN database, which is wrong.
  def follow(follow) do
    with {:ok, follower} <- Actor.get_by_username(follow.follower.preferred_username),
    {:ok, followed} <- MoodleNet.Meta.follow(follow.followed),
    {:ok, followed} <- Actor.get_or_fetch_by_username(followed.preferred_username) do
      #FIXME: insert pointer in AP database?
      ActivityPub.follow(follower, followed)
    else
      _e -> :error
    end
  end

  def unfollow(follow) do
    with {:ok, follower} <- Actor.get_by_username(follow.follower.preferred_username),
    {:ok, followed} <- MoodleNet.Meta.follow(follow.followed),
    {:ok, followed} <- Actor.get_or_fetch_by_username(followed.preferred_username) do
      ActivityPub.unfollow(follower, followed)
    else
      _e -> :error
    end
  end

  @spec run(Map.t()) :: :ok | {:error, any()}
  def run(_map) do
    :ok
  end
end
