# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Test.GraphQLAssertions do
  
  import ExUnit.Assertions

  def assert_location(loc) do
    assert %{"column" => col, "line" => line} = loc
    assert is_integer(col) and col >= 0
    assert is_integer(line) and line >= 1
  end

  def assert_not_logged_in(errs, path) do
    assert [err] = errs
    assert %{"code" => code, "message" => message} = err
    assert %{"path" => path2, "locations" => [loc]} = err
    assert code == "unauthorized"
    assert message == "You need to log in first."
    assert path == path2
    assert_location(loc)
  end

  def assert_not_permitted(errs, path) do
    assert [err] = errs
    assert %{"code" => code, "message" => message} = err
    assert %{"path" => ^path, "locations" => [loc]} = err
    assert code == "unauthorized"
    assert message == "You do not have permission to see this."
    assert_location(loc)
  end

  def assert_not_found(errs, path) do
    assert [err] = errs
    assert %{"code" => code, "message" => message} = err
    assert %{"path" => ^path, "locations" => [loc]} = err
    assert code == "not_found"
    assert message == "not found"
    assert_location(loc)
  end

  def assert_auth_payload(ap) do
    assert %{"token" => token, "me" => me} = ap
    assert is_binary(token)
    assert_me(me)
    assert %{"__typename" => "AuthPayload"} = ap
  end
  def assert_me(me) do
    assert %{"email" => email} = me
    assert is_binary(email)
    assert %{"wantsEmailDigest" => wants_email} = me
    assert is_boolean(wants_email)
    assert %{"wantsNotifications" => wants_notif} = me
    assert is_boolean(wants_notif)
    assert %{"isConfirmed" => true} = me
    assert %{"isInstanceAdmin" => admin} = me
    assert is_boolean(admin)
    assert %{"__typename" => "Me"} = me
  end
  def assert_user(user) do
    assert %{"id" => id, "canonicalUrl" => url} = user
    assert is_binary(id)
    assert is_binary(url)
    assert %{"name" => name, "summary" => summary} = user
    assert is_binary(name)
    assert is_binary(summary)
    assert %{"location" => loc, "website" => website} = user
    assert is_binary(loc)
    assert is_binary(website)
    assert %{"icon" => icon, "image" => image} = user
    assert is_binary(icon)
    assert is_binary(image)
    assert %{"isLocal" => local, "isPublic" => public} = user
    assert %{"isDisabled" => hidden} = user
    assert is_boolean(local)
    assert is_boolean(public)
    assert is_boolean(hidden)
    assert %{"createdAt" => created} = user
    assert %{"updatedAt" => updated} = user
    assert is_binary(created)
    assert is_binary(updated)
    assert %{"__typename" => "User"} = user
  end
  def assert_community(comm) do
    assert %{"id" => id, "canonicalUrl" => url} = comm
    assert is_binary(id)
    assert is_binary(url)
    assert %{"name" => name, "summary" => summary} = comm
    assert is_binary(name)
    assert is_binary(summary)
    assert %{"icon" => icon, "image" => image} = comm
    assert is_binary(icon)
    assert is_binary(image)
    assert %{"isLocal" => local, "isPublic" => public} = comm
    assert %{"isDisabled" => hidden} = comm
    assert is_boolean(local)
    assert is_boolean(public)
    assert is_boolean(hidden)
    assert %{"createdAt" => created} = comm
    assert %{"updatedAt" => updated} = comm
    assert is_binary(created)
    assert is_binary(updated)
    assert %{"__typename" => "Community"} = comm
  end
  def assert_collection(coll) do
    assert %{"id" => id, "canonicalUrl" => url} = coll
    assert is_binary(id)
    assert is_binary(url)
    assert %{"name" => name, "summary" => summary} = coll
    assert is_binary(name)
    assert is_binary(summary)
    assert %{"icon" => icon} = coll
    assert is_binary(icon)
    assert %{"isLocal" => local, "isPublic" => public} = coll
    assert %{"isHidden" => hidden} = coll
    assert is_boolean(local)
    assert is_boolean(public)
    assert is_boolean(hidden)
    assert %{"createdAt" => created} = coll
    assert %{"updatedAt" => updated} = coll
    assert is_binary(created)
    assert is_binary(updated)
    assert %{"__typename" => "Collection"} = coll
  end
  def assert_resource(resource) do
    assert %{"id" => id, "canonicalUrl" => url} = resource
    assert is_binary(id)
    assert is_binary(url)
    assert %{"name" => name, "summary" => summary} = resource
    assert is_binary(id)
    assert is_binary(name)
    assert is_binary(summary)
    assert %{"icon" => icon, "image" => image} = resource
    assert is_binary(icon)
    assert is_binary(image)
    assert %{"url" => url, "license" => license} = resource
    assert is_binary(url)
    assert is_binary(license)
    assert %{"isLocal" => local, "isPublic" => public} = resource
    assert %{"isHidden" => hidden} = resource
    assert is_boolean(local)
    assert is_boolean(public)
    assert is_boolean(hidden)
    assert %{"createdAt" => created} = resource
    assert %{"updatedAt" => updated} = resource
    assert is_binary(created)
    assert is_binary(updated)
    assert %{"__typename" => "Resource"} = resource
  end
  def assert_thread(thread) do
    assert %{"id" => id, "canonicalUrl" => url} = thread
    assert is_binary(id)
    assert is_binary(url)
    assert %{"isLocal" => local, "isPublic" => public} = thread
    assert %{"isHidden" => hidden} = thread
    assert is_boolean(local)
    assert is_boolean(public)
    assert is_boolean(hidden)
    assert %{"createdAt" => created} = thread
    assert %{"updatedAt" => updated} = thread
    assert is_binary(created)
    assert is_binary(updated)
    assert %{"__typename" => "Thread"} = thread
  end
  def assert_comment(comment) do
    assert %{"id" => id, "canonicalUrl" => url} = comment
    assert is_binary(id)
    assert is_binary(url)
    assert %{"id" => id, "inReplyToId" => reply} = comment
    assert is_binary(id)
    assert is_binary(reply)
    assert %{"content" => content} = comment
    assert is_binary(content)
    assert %{"isLocal" => local, "isPublic" => public} = comment
    assert %{"isHidden" => hidden} = comment
    assert is_boolean(local)
    assert is_boolean(public)
    assert is_boolean(hidden)
    assert %{"createdAt" => created} = comment
    assert %{"updatedAt" => updated} = comment
    assert is_binary(created)
    assert is_binary(updated)
    assert %{"__typename" => "Comment"} = comment
  end
  def assert_like(like) do
    assert %{"id" => id, "canonicalUrl" => url} = like
    assert is_binary(id)
    assert is_binary(url)
    assert %{"isLocal" => local, "isPublic" => public} = like
    assert is_boolean(local)
    assert is_boolean(public)
    assert %{"createdAt" => created} = like
    assert is_binary(created)
    assert %{"__typename" => "Like"} = like
  end
  def assert_flag(flag) do
    assert %{"id" => id, "canonicalUrl" => url} = flag
    assert is_binary(id)
    assert is_binary(url)
    assert %{"message" => message, "isResolved" => resolved} = flag
    assert is_binary(message)
    assert is_boolean(resolved)
    assert %{"isLocal" => local, "isPublic" => public} = flag
    assert is_boolean(local)
    assert is_boolean(public)
    assert %{"createdAt" => created} = flag
    assert %{"updatedAt" => updated} = flag
    assert is_binary(created)
    assert is_binary(updated)
    assert %{"__typename" => "Flag"} = flag
  end
  def assert_category(cat) do
    assert %{"id" => id, "canonicalUrl" => url} = cat
    assert is_binary(id)
    assert is_binary(url)
    assert %{"id" => id, "name" => name} = cat
    assert is_binary(id)
    assert is_binary(name)
    assert %{"isLocal" => local, "isPublic" => public} = cat
    assert is_boolean(local)
    assert is_boolean(public)
    assert %{"createdAt" => created} = cat
    assert is_binary(created)
    assert %{"__typename" => "Category"} = cat
  end
  def assert_tag(tag) do
    assert %{"id" => id, "canonicalUrl" => url} = tag
    assert is_binary(id)
    assert is_binary(url)
    assert %{"id" => id, "name" => name} = tag
    assert is_binary(id)
    assert is_binary(name)
    assert %{"isLocal" => local, "isPublic" => public} = tag
    assert is_boolean(local)
    assert is_boolean(public)
    assert %{"createdAt" => created} = tag
    assert is_binary(created)
    assert %{"__typename" => "Tag"} = tag
  end
  def assert_tagging(tag) do
    assert %{"id" => id, "canonicalUrl" => url} = tag
    assert is_binary(id)
    assert is_binary(url)
    assert %{"isLocal" => local, "isPublic" => public} = tag
    assert is_boolean(local)
    assert is_boolean(public)
    assert %{"createdAt" => created} = tag
    assert is_binary(created)
    assert %{"__typename" => "Tagging"} = tag
  end
  def assert_follow(follow) do
    assert %{"id" => id, "canonicalUrl" => url} = follow
    assert is_binary(id)
    assert is_binary(url)
    assert %{"isLocal" => local, "isPublic" => public} = follow
    assert is_boolean(local)
    assert is_boolean(public)
    assert %{"createdAt" => created} = follow
    assert is_binary(created)
    assert %{"__typename" => "Follow"} = follow
  end
  def assert_flag_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "collection" -> assert_collection(thing)
      "comment" -> assert_comment(thing)
      "community" -> assert_community(thing)
      "resource" -> assert_resource(thing)
      "user" -> assert_user(thing)
    end
  end
  def assert_like_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "collection" -> assert_collection(thing)
      "comment" -> assert_comment(thing)
      "resource" -> assert_resource(thing)
      "user" -> assert_user(thing)
    end
  end
  def assert_follow_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "collection" -> assert_collection(thing)
      "community" -> assert_community(thing)
      "thread" -> assert_thread(thing)
      "user" -> assert_user(thing)
    end
  end
  def assert_like_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "collection" -> assert_collection(thing)
      "comment" -> assert_comment(thing)
      "resource" -> assert_resource(thing)
      "user" -> assert_user(thing)
    end
  end
  def assert_tagging_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "collection" -> assert_collection(thing)
      "comment" -> assert_comment(thing)
      "community" -> assert_community(thing)
      "resource" -> assert_resource(thing)
      "thread" -> assert_thread(thing)
      "user" -> assert_user(thing)
    end
  end
  def assert_activity_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "collection" -> assert_collection(thing)
      "comment" -> assert_comment(thing)
      "community" -> assert_community(thing)
      "resource" -> assert_resource(thing)
    end
  end

  # def assert_block(block) do
  # end
end
