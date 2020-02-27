# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.ActivityPub.Publisher do
  alias ActivityPub.Actor
  alias MoodleNet.ActivityPub.Utils
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Repo

  @public_uri "https://www.w3.org/ns/activitystreams#Public"

  # FIXME: this will break if parent is an object that isn't in AP database or doesn't have a pointer_id filled
  def comment(comment) do
    try do
      comment = Repo.preload(comment, thread: :context)
      context = Pointers.follow!(comment.thread.context)

      with object_ap_id = Utils.get_object_ap_id(context),
           {:ok, actor} <- ActivityPub.Actor.get_cached_by_local_id(comment.creator_id),
           {to, cc} <- Utils.determine_recipients(actor, context),
           object = %{
             "content" => comment.content,
             "to" => to,
             "cc" => cc,
             "actor" => actor.ap_id,
             "attributedTo" => actor.ap_id,
             "type" => "Note",
             "inReplyTo" => Utils.get_in_reply_to(comment),
             "context" => object_ap_id
           },
           params = %{
             actor: actor,
             to: to,
             object: object,
             context: object_ap_id,
             additional: %{
               "cc" => cc
             }
           } do
        ActivityPub.create(params, comment.id)
      else
        _e -> :error
      end
    rescue
      _ -> :error
    catch
      _ -> :error
    end
  end

  def delete_comment_or_resource(comment) do
    with %ActivityPub.Object{} = object <- ActivityPub.Object.get_cached_by_pointer_id(comment.id) do
      ActivityPub.delete(object)
    else
      _e -> :error
    end
  end

  def create_resource(resource) do
    with {:ok, collection} <- ActivityPub.Actor.get_cached_by_local_id(resource.collection_id),
         {:ok, actor} <- ActivityPub.Actor.get_cached_by_local_id(resource.creator_id),
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
         params = %{
           actor: actor,
           to: [@public_uri, collection.ap_id],
           object: object,
           context: collection.ap_id,
           additional: %{
             "cc" => [actor.data["followers"]]
           }
         },
         {:ok, activity} <- ActivityPub.create(params, resource.id) do
      Ecto.Changeset.change(resource, %{canonical_url: activity.object.data["id"]})
      |> Repo.update()

      {:ok, activity}
    else
      _e -> :error
    end
  end

  def create_community(community) do
    with {:ok, actor} <- ActivityPub.Actor.get_cached_by_local_id(community.creator_id),
         {:ok, ap_community} <- ActivityPub.Actor.get_cached_by_local_id(community.id),
         community_object <-
           ActivityPubWeb.ActorView.render("actor.json", %{actor: ap_community}),
         params <- %{
           actor: actor,
           to: [@public_uri],
           object: community_object,
           context: ActivityPub.Utils.generate_context_id(),
           additional: %{
             "cc" => [actor.data["followers"]]
           }
         },
         {:ok, activity} <- ActivityPub.create(params) do
      Ecto.Changeset.change(community.actor, %{canonical_url: community_object["id"]})
      |> Repo.update()

      {:ok, activity}
    else
      {:error, e} -> {:error, e}
    end
  end

  def create_collection(collection) do
    with {:ok, actor} <- ActivityPub.Actor.get_cached_by_local_id(collection.creator_id),
         {:ok, ap_collection} <- ActivityPub.Actor.get_cached_by_local_id(collection.id),
         collection_object <-
           ActivityPubWeb.ActorView.render("actor.json", %{actor: ap_collection}),
         {:ok, ap_community} <- ActivityPub.Actor.get_cached_by_local_id(collection.community_id),
         params <- %{
           actor: actor,
           to: [@public_uri, ap_community.ap_id],
           object: collection_object,
           context: ActivityPub.Utils.generate_context_id(),
           additional: %{
             "cc" => [actor.data["followers"]]
           }
         },
         {:ok, activity} <- ActivityPub.create(params) do
      Ecto.Changeset.change(collection.actor, %{canonical_url: collection_object["id"]})
      |> Repo.update()

      {:ok, activity}
    else
      _e -> :error
    end
  end

  ## FIXME: this is currently implemented in a spec non-conforming way, AP follows are supposed to be handshakes
  ## that are only reflected in the host database upon receiving an Accept activity in response. in this case
  ## the follow activity is created based on a Follow object that's already in MN database, which is wrong.
  ## For now we just delete the folow and return an error if the followed account is private.
  def follow(follow) do
    follow = Repo.preload(follow, creator: :actor, context: [])

    with {:ok, follower} <- Actor.get_cached_by_username(follow.creator.actor.preferred_username),
         followed = Pointers.follow!(follow.context),
         {:ok, followed} <- Actor.get_or_fetch_by_username(followed.actor.preferred_username) do
      if followed.data["manuallyApprovesFollowers"] do
        MoodleNet.Follows.undo(follow)
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
    follow = Repo.preload(follow, creator: :actor, context: [])

    with {:ok, follower} <- Actor.get_cached_by_username(follow.creator.actor.preferred_username),
         followed = Pointers.follow!(follow.context),
         {:ok, followed} <- Actor.get_or_fetch_by_username(followed.actor.preferred_username) do
      ActivityPub.unfollow(follower, followed)
    else
      _e -> :error
    end
  end

  def block(block) do
    block = Repo.preload(block, creator: :actor, context: [])

    with {:ok, blocker} <- Actor.get_cached_by_username(block.creator.actor.preferred_username),
         blocked = Pointers.follow!(block.context),
         {:ok, blocked} <- Actor.get_or_fetch_by_username(blocked.actor.preferred_username) do
      # FIXME: insert pointer in AP database, insert cannonical URL in MN database
      ActivityPub.block(blocker, blocked)
    else
      _e -> :error
    end
  end

  def unblock(block) do
    block = Repo.preload(block, creator: :actor, context: [])

    with {:ok, blocker} <- Actor.get_cached_by_username(block.creator.actor.preferred_username),
         blocked = Pointers.follow!(block.context),
         {:ok, blocked} <- Actor.get_or_fetch_by_username(blocked.actor.preferred_username) do
      ActivityPub.unblock(blocker, blocked)
    else
      _e -> :error
    end
  end

  def like(like) do
    like = Repo.preload(like, :context)

    with {:ok, liker} <- Actor.get_cached_by_local_id(like.creator_id) do
      liked = Pointers.follow!(like.context)
      object = Utils.get_object(liked)
      ActivityPub.like(liker, object)
    else
      _e -> :error
    end
  end

  def unlike(like) do
    like = Repo.preload(like, :context)

    with {:ok, liker} <- Actor.get_cached_by_local_id(like.creator_id) do
      liked = Pointers.follow!(like.context)
      object = Utils.get_object(liked)
      ActivityPub.unlike(liker, object)
    else
      _e -> :error
    end
  end

  def flag(flag) do
    flag = Repo.preload(flag, creator: :actor, context: [])

    with {:ok, flagger} <- Actor.get_cached_by_username(flag.creator.actor.preferred_username) do
      flagged = Pointers.follow!(flag.context)

      # FIXME: this is kinda stupid, need to figure out a better way to handle meta-participating objects
      params =
        case flagged do
          %{creator_id: id} when not is_nil(id) ->
            flagged = Repo.preload(flagged, creator: :actor)

            {:ok, account} =
              ActivityPub.Actor.get_or_fetch_by_username(flagged.creator.actor.preferred_username)

            %{
              statuses: [ActivityPub.Object.get_cached_by_pointer_id(flagged.id)],
              account: account
            }

          %{actor_id: id} when not is_nil(id) ->
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
          content: flag.message,
          forward: true
        },
        flag.id
      )
    else
      _e -> :error
    end
  end

  # Works for Users, Collections, Communities (not MN.Actor)
  def update_actor(actor) do
    with {:ok, actor} <- ActivityPub.Actor.get_by_local_id(actor.id),
         actor_object <- ActivityPubWeb.ActorView.render("actor.json", %{actor: actor}),
         params <- %{
           to: [@public_uri],
           cc: [actor.data["followers"]],
           object: actor_object,
           actor: actor.ap_id,
           local: true
         } do
      ActivityPub.update(params)
      ActivityPub.Actor.set_cache(actor)
    else
      _e -> :error
    end
  end

  # Works for Users, Collections, Communities (not MN.Actor)
  def delete_actor(actor) do
    with {:ok, actor} <- ActivityPub.Actor.get_cached_by_local_id(actor.id) do
      ActivityPub.delete(actor)
      # FIXME: currently the cache will get re-set when the delete activity is being federated
      ActivityPub.Actor.invalidate_cache(actor)
    end
  end
end
