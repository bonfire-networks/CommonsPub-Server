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
           "attributedTo" => actor.ap_id,
           "type" => "Note",
           "inReplyTo" => Utils.get_in_reply_to(comment)
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
      # FIXME: pointer_id isn't getting inserted for whatever reason
      ActivityPub.create(params, comment.id)
    else
      _e -> :error
    end
  end

  ## FIXME: this is currently implemented in a spec non-conforming way, AP follows are supposed to be handshakes
  ## that are only reflected in the host database upon receiving an Accept activity in response. in this case
  ## the follow activity is created based on a Follow object that's already in MN database, which is wrong.
  ## For now we just delete the folow and return an error if the followed account is private.
  def follow(follow) do
    with {:ok, follower} <- Actor.get_by_username(follow.follower.preferred_username),
         {:ok, followed} <- MoodleNet.Meta.follow(follow.followed),
         {:ok, followed} <- Actor.get_or_fetch_by_username(followed.preferred_username) do
      if followed.data["manuallyApprovesFollowers"] do
        MoodleNet.Common.unfollow(follow)
        {:error, "account is private"}
      else
        # FIXME: insert pointer in AP database?
        ActivityPub.follow(follower, followed)
      end
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

  def block(block) do
    with {:ok, blocker} <- Actor.get_by_username(block.blocker.preferred_username),
         {:ok, blocked} <- MoodleNet.Meta.follow(block.blocked),
         {:ok, blocked} <- Actor.get_or_fetch_by_username(blocked.preferred_username) do
      # FIXME: insert pointer in AP database?
      ActivityPub.block(blocker, blocked)
    else
      _e -> :error
    end
  end

  def unblock(block) do
    with {:ok, blocker} <- Actor.get_by_username(block.blocker.preferred_username),
         {:ok, blocked} <- MoodleNet.Meta.follow(block.blocked),
         {:ok, blocked} <- Actor.get_or_fetch_by_username(blocked.preferred_username) do
      ActivityPub.unblock(blocker, blocked)
    else
      _e -> :error
    end
  end

  def flag(flag) do
    with {:ok, flagger} <- Actor.get_by_username(flag.flagger.preferred_username),
         {:ok, flagged} <- MoodleNet.Meta.follow(flag.flagged) do
      # FIXME: this is kinda stupid, need to figure out a better way to handle meta-participating objects
      params =
        case flagged do
          %MoodleNet.Comments.Comment{} ->
            flagged = MoodleNet.Repo.preload(flagged, :creator)

            {:ok, account} =
              ActivityPub.Actor.get_or_fetch_by_username(flagged.creator.preferred_username)

            %{
              statuses: [ActivityPub.Object.get_by_pointer_id(flagged.id)],
              account: account
            }

          _ ->
            {:ok, account} =
              ActivityPub.Actor.get_or_fetch_by_username(flagged.preferred_username)

            %{
              statuses: nil,
              account: account
            }
        end

      ActivityPub.flag(
        %{
          actor: flagger,
          context: ActivityPub.Utils.generate_context_id(),
          statuses: params.statuses,
          account: params.account,
          content: flag.message
        },
        flag.id
      )
    else
      _e -> :error
    end
  end
end
