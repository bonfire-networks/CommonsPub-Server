defmodule MoodleNet.ActivityPub.Publisher do
  alias ActivityPub.Actor
  alias MoodleNet.Repo
  alias MoodleNet.ActivityPub.Utils

  @public_uri "https://www.w3.org/ns/activitystreams#Public"

  # FIXME: this will break if parent is an object that isn't in AP database or doesn't have a pointer_id filled
  def comment(comment) do
    comment = Repo.preload(comment, thread: :context)

    with {:ok, context} <- MoodleNet.Meta.follow(comment.thread.context),
         object_ap_id <- Utils.get_object_ap_id(context),
         {:ok, actor} <- ActivityPub.Actor.get_by_local_id(comment.creator_id),
         {to, cc} <- Utils.determine_recipients(actor, context),
         object <- %{
           "content" => comment.content,
           "to" => to,
           "cc" => cc,
           "actor" => actor.ap_id,
           "attributedTo" => actor.ap_id,
           "type" => "Note",
           "inReplyTo" => Utils.get_in_reply_to(comment),
           "context" => object_ap_id
         },
         params <- %{
           actor: actor,
           to: to,
           object: object,
           context: object_ap_id,
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

  def create_resource(resource) do
    with {:ok, collection} <- ActivityPub.Actor.get_by_local_id(resource.collection_id),
         {:ok, actor} <- ActivityPub.Actor.get_by_local_id(resource.creator_id),
         object <- %{
           "name" => resource.name,
           "url" => resource.url,
           "icon" => Map.get(resource, :icon),
           "actor" => actor.ap_id,
           "attributedTo" => actor.ap_id,
           "context" => collection.ap_id,
           "summary" => Map.get(resource, :summary),
           "type" => "Document",
           "tag" => resource.license
         },
         params <- %{
           actor: actor,
           to: [@public_uri],
           object: object,
           context: collection.ap_id,
           additional: %{
             "cc" => [collection.data["followers"], actor.data["followers"]]
           }
         } do
      ActivityPub.create(params, resource.id)
    else
      _e -> :error
    end
  end

  def create_community(community) do
    with {:ok, actor} <- ActivityPub.Actor.get_by_local_id(community.creator_id),
         {:ok, ap_community} <- ActivityPub.Actor.get_by_local_id(community.id),
         community_object <- ActivityPubWeb.ActorView.render("actor.json", %{actor: ap_community}),
         params <- %{
          actor: actor,
          to: [@public_uri],
          object: community_object,
          context: ActivityPub.Utils.generate_context_id(),
          additional: %{
            "cc" => [actor.data["followers"]]
          }
        } do
     ActivityPub.create(params)
    else
      {:error, e} -> {:error, e}
    end
  end

  def create_collection(collection) do
    with {:ok, actor} <- ActivityPub.Actor.get_by_local_id(collection.creator_id),
         {:ok, ap_collection} <- ActivityPub.Actor.get_by_local_id(collection.id),
         collection_object <- ActivityPubWeb.ActorView.render("actor.json", %{actor: ap_collection}),
         {:ok, ap_community} <- ActivityPub.Actor.get_by_local_id(collection.community_id),
         params <- %{
          actor: actor,
          to: [@public_uri],
          object: collection_object,
          context: ActivityPub.Utils.generate_context_id(),
          additional: %{
            "cc" => [actor.data["followers"], ap_community.data["followers"]]
          }
        } do
     ActivityPub.create(params)
    else
      _e -> :error
    end
  end

  ## FIXME: this is currently implemented in a spec non-conforming way, AP follows are supposed to be handshakes
  ## that are only reflected in the host database upon receiving an Accept activity in response. in this case
  ## the follow activity is created based on a Follow object that's already in MN database, which is wrong.
  ## For now we just delete the folow and return an error if the followed account is private.
  def follow(follow) do
    follow = Repo.preload(follow, follower: :actor, followed: [])

    with {:ok, follower} <- Actor.get_by_username(follow.follower.actor.preferred_username),
         {:ok, followed} <- MoodleNet.Meta.follow(follow.followed),
         followed <- Repo.preload(followed, :actor),
         {:ok, followed} <- Actor.get_or_fetch_by_username(followed.actor.preferred_username) do
      if followed.data["manuallyApprovesFollowers"] do
        MoodleNet.Common.undo_follow(follow)
        {:error, "account is private"}
      else
        # FIXME: insert pointer in AP database, insert cannonical URL in MN database
        ActivityPub.follow(follower, followed)
      end
    else
      _e -> :error
    end
  end

  def unfollow(follow) do
    follow = Repo.preload(follow, follower: :actor, followed: [])

    with {:ok, follower} <- Actor.get_by_username(follow.follower.actor.preferred_username),
         {:ok, followed} <- MoodleNet.Meta.follow(follow.followed),
         followed <- Repo.preload(followed, :actor),
         {:ok, followed} <- Actor.get_or_fetch_by_username(followed.actor.preferred_username) do
      ActivityPub.unfollow(follower, followed)
    else
      _e -> :error
    end
  end

  def block(block) do
    block = Repo.preload(block, blocker: :actor, blocked: [])

    with {:ok, blocker} <- Actor.get_by_username(block.blocker.actor.preferred_username),
         {:ok, blocked} <- MoodleNet.Meta.follow(block.blocked),
         blocked <- Repo.preload(blocked, :actor),
         {:ok, blocked} <- Actor.get_or_fetch_by_username(blocked.actor.preferred_username) do
      # FIXME: insert pointer in AP database, insert cannonical URL in MN database
      ActivityPub.block(blocker, blocked)
    else
      _e -> :error
    end
  end

  def unblock(block) do
    block = Repo.preload(block, blocker: :actor, blocked: [])

    with {:ok, blocker} <- Actor.get_by_username(block.blocker.actor.preferred_username),
         {:ok, blocked} <- MoodleNet.Meta.follow(block.blocked),
         blocked <- Repo.preload(blocked, :actor),
         {:ok, blocked} <- Actor.get_or_fetch_by_username(blocked.actor.preferred_username) do
      ActivityPub.unblock(blocker, blocked)
    else
      _e -> :error
    end
  end

  def like(like) do
    like = Repo.preload(like, :liked)

    with {:ok, liker} <- Actor.get_by_local_id(like.liker_id),
         {:ok, liked} <- MoodleNet.Meta.follow(like.liked),
         object <- Utils.get_object(liked) do
      ActivityPub.like(liker, object)
    else
      _e -> :error
    end
  end

  def unlike(like) do
    like = Repo.preload(like, :liked)

    with {:ok, liker} <- Actor.get_by_local_id(like.liker_id),
         {:ok, liked} <- MoodleNet.Meta.follow(like.liked),
         object <- Utils.get_object(liked) do
      ActivityPub.unlike(liker, object)
    else
      _e -> :error
    end
  end

  def flag(flag) do
    flag = Repo.preload(flag, flagger: :actor, flagged: [])

    with {:ok, flagger} <- Actor.get_by_username(flag.flagger.actor.preferred_username),
         {:ok, flagged} <- MoodleNet.Meta.follow(flag.flagged) do
      # FIXME: this is kinda stupid, need to figure out a better way to handle meta-participating objects
      params =
        case flagged do
          %MoodleNet.Comments.Comment{} ->
            flagged = Repo.preload(flagged, creator: :actor)

            {:ok, account} =
              ActivityPub.Actor.get_or_fetch_by_username(flagged.creator.actor.preferred_username)

            %{
              statuses: [ActivityPub.Object.get_by_pointer_id(flagged.id)],
              account: account
            }

          _ ->
            flagged = Repo.preload(flagged, :actor)

            {:ok, account} =
              ActivityPub.Actor.get_or_fetch_by_username(flagged.actor.preferred_username)

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
