# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Test.GraphQLAssertions do

  alias MoodleNet.Activities.Activity
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Comments.{Thread, Comment}
  alias MoodleNet.Common.{Flag, Follow, Like}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User
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
    assert code == "needs_login"
    assert message == "You need to log in first."
    assert path == path2
    assert_location(loc)
  end

  def assert_not_permitted(errs, path, verb \\ "do") do
    assert [err] = errs
    assert %{"code" => code, "message" => message} = err
    assert %{"path" => ^path, "locations" => [loc]} = err
    assert code == "unauthorized"
    assert message == "You do not have permission to #{verb} this."
    assert_location(loc)
  end

  def assert_not_found(errs, path) do
    assert [err] = errs
    assert %{"code" => code, "message" => message} = err
    assert %{"path" => ^path, "locations" => [loc]} = err
    assert code == "not_found"
    assert message == "Not found"
    assert_location(loc)
  end

  def assert_invalid_credential(errs, path) do
    assert [err] = errs
    assert %{"code" => code, "message" => message} = err
    assert %{"path" => ^path, "locations" => [loc]} = err
    assert code == "invalid_credential"
    assert message == "We couldn't find an account with these details"
    assert_location(loc)
  end

  def assert_node_list(list) do
    assert %{"pageInfo" => page, "totalCount" => count} = list
    assert is_integer(count)
    assert %{"startCursor" => start, "endCursor" => ends} = page
    assert is_binary(start)
    assert is_binary(ends)
    assert %{"nodes" => nodes} = list
    assert is_list(nodes)
    page_info = %{start_cursor: start, end_cursor: ends}
    %{page_info: page_info, nodes: nodes}
  end

  

  def assert_edge_list(list, cursor_fn \\ &(&1.id)) do
    assert %{"pageInfo" => page, "totalCount" => count} = list
    assert is_integer(count)
    assert %{"startCursor" => start, "endCursor" => ends} = page
    assert is_binary(start)
    assert is_binary(ends)
    assert %{"edges" => edges} = list
    assert is_list(edges)
    edges = Enum.map(edges, fn e ->
      assert %{"cursor" => cursor, "node" => node} = e
      assert is_binary(cursor)
      Map.merge(e, %{cursor: cursor, node: node})
    end)
    page_info = %{start_cursor: start, end_cursor: ends}
    %{page_info: page_info, total_count: count, edges: edges}
  end

  def assert_language(lang) do
    assert %{"id" => id, "isoCode2" => c2, "isoCode3" => c3} = lang
    assert is_binary(id)
    assert is_binary(c2)
    assert is_binary(c3)
    assert %{"englishName" => name, "localName" => naam} = lang
    assert is_binary(name)
    assert is_binary(naam)
    # assert %{"createdAt" => created, "updatedAt" => updated} = lang
    # assert is_binary(created)
    # assert is_binary(updated)
  end
  def assert_country(country), do: assert_language(country)

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
    assert %{"isConfirmed" => confirmed} = me
    assert %{"isInstanceAdmin" => admin} = me
    assert %{"user" => user} = me
    user = assert_user(user)
    assert is_boolean(admin)
    assert %{"__typename" => "Me"} = me
    %{email: email,
      wants_email_digest: wants_email,
      wants_notifications: wants_notif,
      is_confirmed: confirmed,
      is_instance_admin: admin,
      user: user}
    |> Map.merge(me)
  end
  def assert_me(%User{}=user, %{}=me) do
    me = assert_me(me)
    assert user.local_user.email == me.email
    assert user.local_user.wants_email_digest == me.wants_email_digest
    assert user.local_user.wants_notifications == me.wants_notifications
    user2 = me.user
    assert user.id == user2.id
    assert user.actor.preferred_username == user2.preferred_username
    assert user.name == user2.name
    assert user.summary == user2.summary
    assert user.location == user2.location
    assert user.website == user2.website
    assert user.icon == user2.icon
    assert user.image == user2.image
    me
  end

  def assert_user(user) do
    assert %{"id" => id, "canonicalUrl" => url} = user
    assert is_binary(id)
    assert is_binary(url) or is_nil(url) or is_nil(url)
    assert %{"preferredUsername" => username} = user
    assert is_binary(username)
    assert %{"name" => name, "summary" => summary} = user
    assert is_binary(name)
    assert is_binary(summary) or is_nil(summary)
    assert %{"location" => loc, "website" => website} = user
    assert is_binary(loc) or is_nil(loc)
    assert is_binary(website) or is_nil(website)
    assert %{"icon" => icon, "image" => image} = user
    assert is_binary(icon) or is_nil(icon)
    assert is_binary(image) or is_nil(image)
    assert %{"isLocal" => local, "isPublic" => public} = user
    assert %{"isDisabled" => disabled} = user
    assert is_boolean(local)
    assert is_boolean(public)
    assert is_boolean(disabled)
    assert %{"createdAt" => created} = user
    assert %{"updatedAt" => updated} = user
    assert is_binary(created)
    assert is_binary(updated)
    assert {:ok, created_at,0} = DateTime.from_iso8601(created)
    assert {:ok, updated_at,0} = DateTime.from_iso8601(updated)
    assert %{"__typename" => "User"} = user
    %{id: id,
      canonical_url: url,
      preferred_username: username,
      name: name,
      summary: summary,
      location: loc,
      website: website,
      icon: icon,
      image: image,
      is_local: local,
      is_public: public,
      is_disabled: disabled,
      created_at: created_at,
      updated_at: updated_at }
    |> Map.merge(user)
  end
  def assert_user(%User{}=user, %{}=user2) do
    user2 = assert_user(user2)
    assert user.id == user2.id
    assert user.actor.canonical_url == user2.canonical_url
    assert user.actor.preferred_username == user2.preferred_username
    assert user.name == user2.name
    assert user.summary == user2.summary
    assert user.location == user2.location
    assert user.website == user2.website
    assert user.icon == user2.icon
    assert user.image == user2.image
    assert user.created_at == user2.created_at
    assert user.updated_at == user2.updated_at
    assert user2.is_public == true
    assert user2.is_disabled == false
    assert user2.is_local == true
    user2
  end

  def assert_community(comm) do
    assert %{"id" => id, "canonicalUrl" => url} = comm
    assert is_binary(id)
    assert is_binary(url) or is_nil(url)
    assert %{"preferredUsername" => username} = comm
    assert is_binary(username)
    assert %{"name" => name, "summary" => summary} = comm
    assert is_binary(name)
    assert is_binary(summary)
    assert %{"icon" => icon, "image" => image} = comm
    assert is_binary(icon)
    assert is_binary(image)
    assert %{"isLocal" => local, "isPublic" => public} = comm
    assert %{"isDisabled" => disabled} = comm
    assert is_boolean(local)
    assert is_boolean(public)
    assert is_boolean(disabled)
    assert %{"createdAt" => created} = comm
    assert %{"updatedAt" => updated} = comm
    assert is_binary(created)
    assert is_binary(updated)
    assert {:ok, created_at,0} = DateTime.from_iso8601(created)
    assert {:ok, updated_at,0} = DateTime.from_iso8601(updated)
    assert %{"__typename" => "Community"} = comm
    %{id: id,
      canonical_url: url,
      preferred_username: username,
      name: name,
      summary: summary,
      icon: icon,
      image: image,
      is_local: local,
      is_public: public,
      is_disabled: disabled,
      created_at: created_at,
      updated_at: updated_at }
    |> Map.merge(comm)
  end

  def assert_community(%Community{}=comm, %{}=comm2) do
    comm2 = assert_community(comm2)
    assert comm.id == comm2.id
    assert comm.actor.canonical_url == comm2.canonical_url
    assert comm.actor.preferred_username == comm2.preferred_username
    assert comm.name == comm2.name
    assert comm.summary == comm2.summary
    assert comm.icon == comm2.icon
    assert comm.image == comm2.image
    assert comm.is_local == comm2.is_local
    assert comm.is_public == comm2.is_public
    assert comm.is_disabled == comm2.is_disabled
    assert comm.created_at == comm2.created_at
    assert comm.updated_at == comm2.updated_at
    comm2
  end


  def assert_collection(coll) do
    assert %{"id" => id, "canonicalUrl" => url} = coll
    assert is_binary(id)
    assert is_binary(url) or is_nil(url)
    assert %{"preferredUsername" => username} = coll
    assert is_binary(username)
    assert %{"name" => name, "summary" => summary} = coll
    assert is_binary(name)
    assert is_binary(summary)
    assert %{"icon" => icon} = coll
    assert is_binary(icon)
    assert %{"isLocal" => local, "isPublic" => public} = coll
    assert %{"isDisabled" => disabled} = coll
    assert is_boolean(local)
    assert is_boolean(public)
    assert is_boolean(disabled)
    assert %{"createdAt" => created} = coll
    assert %{"updatedAt" => updated} = coll
    assert is_binary(created)
    assert is_binary(updated)
    assert {:ok, created_at,0} = DateTime.from_iso8601(created)
    assert {:ok, updated_at,0} = DateTime.from_iso8601(updated)
    assert %{"__typename" => "Collection"} = coll
    %{id: id,
      canonical_url: url,
      preferred_username: username,
      name: name,
      summary: summary,
      icon: icon,
      is_local: local,
      is_public: public,
      is_disabled: disabled,
      created_at: created_at,
      updated_at: updated_at }
    |> Map.merge(coll)
  end

  def assert_collection(%Collection{}=coll, %{}=coll2) do
    coll2 = assert_collection(coll2)
    assert coll.id == coll2.id
    assert coll.actor.canonical_url == coll2.canonical_url
    assert coll.actor.preferred_username == coll2.preferred_username
    assert coll.name == coll2.name
    assert coll.summary == coll2.summary
    assert coll.icon == coll2.icon
    assert is_nil(coll.actor.peer_id) == coll2.is_local
    assert not is_nil(coll.published_at) == coll2.is_public
    assert not is_nil(coll.disabled_at) == coll2.is_disabled
    assert coll.created_at == coll2.created_at
    assert coll.updated_at == coll2.updated_at
    coll2
  end

  def assert_resource(resource) do
    assert %{"id" => id, "canonicalUrl" => canon_url} = resource
    assert is_binary(id)
    assert is_binary(canon_url) or is_nil(canon_url)
    assert %{"name" => name, "summary" => summary} = resource
    assert is_binary(id)
    assert is_binary(name)
    assert is_binary(summary)
    assert %{"icon" => icon} = resource
    assert is_binary(icon)
    assert %{"url" => url, "license" => license} = resource
    assert is_binary(url) or is_nil(url)
    assert is_binary(license)
    assert %{"isLocal" => local, "isPublic" => public} = resource
    assert %{"isDisabled" => disabled} = resource
    assert is_boolean(local)
    assert is_boolean(public)
    assert is_boolean(disabled)
    assert %{"createdAt" => created} = resource
    assert %{"updatedAt" => updated} = resource
    assert is_binary(created)
    assert is_binary(updated)
    assert {:ok, created_at,0} = DateTime.from_iso8601(created)
    assert {:ok, updated_at,0} = DateTime.from_iso8601(updated)
    assert %{"__typename" => "Resource"} = resource
    %{id: id,
      canonical_url: canon_url,
      name: name,
      summary: summary,
      icon: icon,
      url: url,
      license: license,
      is_local: local,
      is_public: public,
      is_disabled: disabled,
      created_at: created_at,
      updated_at: updated_at }
    |> Map.merge(resource)
  end

  def assert_resource(%Resource{}=res, %{}=res2) do
    res2 = assert_resource(res2)
    assert res.id == res2.id
    assert res.canonical_url == res2.canonical_url
    assert res.name == res2.name
    assert res.summary == res2.summary
    assert res.icon == res2.icon
    assert res.url == res2.url
    assert res.license == res2.license
    assert not is_nil(res.published_at) == res2.is_public
    assert not is_nil(res.disabled_at) == res2.is_disabled
    assert res.created_at == res2.created_at
    assert res.updated_at == res2.updated_at
    res2
  end

  def assert_thread(thread) do
    assert %{"id" => id, "canonicalUrl" => url} = thread
    assert is_binary(id)
    assert is_binary(url) or is_nil(url)
    assert %{"isLocal" => local, "isPublic" => public} = thread
    assert %{"isHidden" => hidden} = thread
    assert is_boolean(local)
    assert is_boolean(public)
    assert is_boolean(hidden)
    assert %{"createdAt" => created} = thread
    assert %{"updatedAt" => updated} = thread
    assert is_binary(created)
    assert is_binary(updated)
    assert {:ok, created_at,0} = DateTime.from_iso8601(created)
    assert {:ok, updated_at,0} = DateTime.from_iso8601(updated)
    assert %{"__typename" => "Thread"} = thread
    %{id: id,
      canonical_url: url,
      is_local: local,
      is_public: public,
      is_hidden: hidden,
      created_at: created_at,
      updated_at: updated_at }
    |> Map.merge(thread)
  end

  def assert_thread(%Thread{}=thread, %{}=thread2) do
    thread2 = assert_thread(thread2)
    assert thread.id == thread2.id
    assert thread.canonical_url == thread2.canonical_url
    assert thread.is_local == thread2.is_local
    assert thread.is_public == thread2.is_public
    assert thread.is_hidden == thread2.is_hidden
    assert thread.created_at == thread2.created_at
    assert thread.updated_at == thread2.updated_at
    thread2
  end
  
  def assert_comment(comment) do
    assert %{"id" => id, "canonicalUrl" => url} = comment
    assert is_binary(id)
    assert is_binary(url) or is_nil(url)
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
    assert {:ok, created_at,0} = DateTime.from_iso8601(created)
    assert {:ok, updated_at,0} = DateTime.from_iso8601(updated)
    assert %{"__typename" => "Comment"} = comment
    %{id: id,
      canonical_url: url,
      content: content,
      is_local: local,
      is_public: public,
      is_hidden: hidden,
      created_at: created_at,
      updated_at: updated_at }
    |> Map.merge(comment)
  end

  def assert_comment(%Comment{}=comment, %{}=comment2) do
    comment2 = assert_comment(comment2)
    assert comment.id == comment2.id
    assert comment.canonical_url == comment2.canonical_url
    assert comment.content == comment2.content
    assert comment.is_local == comment2.is_local
    assert comment.is_public == comment2.is_public
    assert comment.is_hidden == comment2.is_hidden
    assert comment.created_at == comment2.created_at
    assert comment.updated_at == comment2.updated_at
    comment2
  end

  def assert_flag(flag) do
    assert %{"id" => id, "canonicalUrl" => url} = flag
    assert is_binary(id)
    assert is_binary(url) or is_nil(url)
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
    assert {:ok, created_at,0} = DateTime.from_iso8601(created)
    assert {:ok, updated_at,0} = DateTime.from_iso8601(updated)
    assert %{"__typename" => "Flag"} = flag
    %{id: id,
      canonical_url: url,
      message: message,
      is_resolved: resolved,
      is_local: local,
      is_public: public,
      created_at: created_at,
      updated_at: updated_at }
    |> Map.merge(flag)
  end

  def assert_flag(%Flag{}=flag, %{}=flag2) do
    flag2 = assert_flag(flag2)
    assert flag.id == flag2.id
    assert flag.canonical_url == flag2.canonical_url
    assert flag.message == flag2.message
    assert flag.is_resolved == flag2.is_resolved
    assert flag.is_local == flag2.is_local
    assert flag.is_public == flag2.is_public
    assert flag.created_at == flag2.created_at
    assert flag.updated_at == flag2.updated_at
    flag2
  end

  def assert_follow(follow) do
    assert %{"id" => id, "canonicalUrl" => url} = follow
    assert is_binary(id)
    assert is_binary(url) or is_nil(url)
    assert %{"isLocal" => local, "isPublic" => public} = follow
    assert is_boolean(local)
    assert is_boolean(public)
    assert %{"createdAt" => created} = follow
    assert is_binary(created)
    assert {:ok, created_at,0} = DateTime.from_iso8601(created)
    assert %{"__typename" => "Follow"} = follow
    %{id: id,
      canonical_url: url,
      is_local: local,
      is_public: public,
      created_at: created_at }
    |> Map.merge(follow)
  end

  def assert_follow(%Follow{}=follow, %{}=follow2) do
    follow2 = assert_follow(follow2)
    assert follow.id == follow2.id
    assert follow.canonical_url == follow2.canonical_url
    assert follow.is_local == follow2.is_local
    assert follow.is_public == follow2.is_public
    assert follow.created_at == follow2.created_at
    assert follow.updated_at == follow2.updated_at
    follow2
  end

  def assert_like(like) do
    assert %{"id" => id, "canonicalUrl" => url} = like
    assert is_binary(id)
    assert is_binary(url) or is_nil(url)
    assert %{"isLocal" => local, "isPublic" => public} = like
    assert is_boolean(local)
    assert is_boolean(public)
    assert %{"createdAt" => created} = like
    assert is_binary(created)
    assert {:ok, created_at,0} = DateTime.from_iso8601(created)
    assert %{"__typename" => "Like"} = like
    %{id: id,
      canonical_url: url,
      is_local: local,
      is_public: public,
      created_at: created_at }
    |> Map.merge(like)
  end

  def assert_like(%Like{}=like, %{}=like2) do
    like2 = assert_like(like2)
    assert like.id == like2.id
    assert like.canonical_url == like2.canonical_url
    assert like.is_local == like2.is_local
    assert like.is_public == like2.is_public
    assert like.created_at == like2.created_at
    assert like.updated_at == like2.updated_at
    like2
  end


  def assert_activity(activity) do
    assert %{"id" => id, "canonicalUrl" => url} = activity
    assert is_binary(id)
    assert is_binary(url) or is_nil(url)
    assert %{"verb" => verb} = activity
    assert is_binary(verb)
    assert %{"isLocal" => local, "isPublic" => public} = activity
    assert is_boolean(local)
    assert is_boolean(public)
    assert %{"createdAt" => created} = activity
    assert is_binary(created)
    assert {:ok, created_at,0} = DateTime.from_iso8601(created)
    assert %{"__typename" => "Activity"} = activity
    %{id: id,
      canonical_url: url,
      verb: verb,
      is_local: local,
      is_public: public,
      created_at: created_at }
    |> Map.merge(activity)
  end
  def assert_activity(%Activity{}=activity, %{}=activity2) do
    activity2 = assert_activity(activity2)
    assert activity.id == activity2.id
    assert activity.canonical_url == activity2.canonical_url
    assert activity.verb == activity2.verb
    assert activity.is_local == activity2.is_local
    assert activity.is_public == activity2.is_public
    assert activity.created_at == activity2.created_at
    activity2
  end

  def assert_flag_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "Collection" -> assert_collection(thing)
      "Comment" -> assert_comment(thing)
      "Community" -> assert_community(thing)
      "Resource" -> assert_resource(thing)
      "User" -> assert_user(thing)
    end
    |> Map.put(:type, type)
  end
  def assert_like_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "Collection" -> assert_collection(thing)
      "Comment" -> assert_comment(thing)
      "Resource" -> assert_resource(thing)
      "User" -> assert_user(thing)
    end
    |> Map.put(:type, type)
  end
  def assert_follow_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "Collection" -> assert_collection(thing)
      "Community" -> assert_community(thing)
      "Thread" -> assert_thread(thing)
      "User" -> assert_user(thing)
    end
    |> Map.put(:type, type)
  end
  def assert_like_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "Collection" -> assert_collection(thing)
      "Comment" -> assert_comment(thing)
      "Resource" -> assert_resource(thing)
      "User" -> assert_user(thing)
    end
    |> Map.put(:type, type)
  end
  def assert_tagging_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "Collection" -> assert_collection(thing)
      "Comment" -> assert_comment(thing)
      "Community" -> assert_community(thing)
      "Resource" -> assert_resource(thing)
      "Thread" -> assert_thread(thing)
      "User" -> assert_user(thing)
    end
    |> Map.put(:type, type)
  end
  def assert_activity_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "Collection" -> assert_collection(thing)
      "Comment" -> assert_comment(thing)
      "Community" -> assert_community(thing)
      "Resource" -> assert_resource(thing)
    end
    |> Map.put(:type, type)
  end
  def assert_thread_context(thing) do
    assert %{"__typename" => type} = thing
    case type do
      "Collection" -> assert_collection(thing)
      "Community" -> assert_community(thing)
      "Flag" -> assert_flag(thing)
      "Resource" -> assert_resource(thing)
    end
    |> Map.put(:type, type)
  end

  # def assert_tag_category(cat) do
  #   assert %{"id" => id, "canonicalUrl" => url} = cat
  #   assert is_binary(id)
  #   assert is_binary(url) or is_nil(url)
  #   assert %{"id" => id, "name" => name} = cat
  #   assert is_binary(id)
  #   assert is_binary(name)
  #   assert %{"isLocal" => local, "isPublic" => public} = cat
  #   assert is_boolean(local)
  #   assert is_boolean(public)
  #   assert %{"createdAt" => created} = cat
  #   assert is_binary(created)
  #   assert %{"__typename" => "TagCategory"} = cat
  # end
  # def assert_tag(tag) do
  #   assert %{"id" => id, "canonicalUrl" => url} = tag
  #   assert is_binary(id)
  #   assert is_binary(url) or is_nil(url)
  #   assert %{"id" => id, "name" => name} = tag
  #   assert is_binary(id)
  #   assert is_binary(name)
  #   assert %{"isLocal" => local, "isPublic" => public} = tag
  #   assert is_boolean(local)
  #   assert is_boolean(public)
  #   assert %{"createdAt" => created} = tag
  #   assert is_binary(created)
  #   assert %{"__typename" => "Tag"} = tag
  # end
  # def assert_tagging(tag) do
  #   assert %{"id" => id, "canonicalUrl" => url} = tag
  #   assert is_binary(id)
  #   assert is_binary(url) or is_nil(url)
  #   assert %{"isLocal" => local, "isPublic" => public} = tag
  #   assert is_boolean(local)
  #   assert is_boolean(public)
  #   assert %{"createdAt" => created} = tag
  #   assert is_binary(created)
  #   assert %{"__typename" => "Tagging"} = tag
  # end

  # def assert_block(block) do
  # end
end
