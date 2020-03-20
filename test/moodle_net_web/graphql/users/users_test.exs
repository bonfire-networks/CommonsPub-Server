# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UsersTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Trendy
  import MoodleNet.Test.Faking
  alias MoodleNet.{Access, Users}

  describe "username_available" do

    test "works for a guest or a user" do
      alice = fake_user!()
      q = username_available_query()
      for conn <- [json_conn(), user_conn(alice)] do
        vars = %{username: Fake.preferred_username()}
        assert true == gruff_post_key(q, conn, :username_available, vars)
        vars = %{username: alice.actor.preferred_username}
        assert false == gruff_post_key(q, conn, :username_available, vars)
      end
    end

  end

  describe "me" do

    test "works for a logged in user" do
      alice = fake_user!()
      q = me_query()
      me = gruff_post_key(q, user_conn(alice), :me)
      assert_me(alice, me)
    end

    test "does not work for a guest" do
      assert_not_logged_in(gruff_post_errors(me_query(), json_conn()), ["me"])
    end

  end

  describe "user" do

    test "Works for anyone with a public user" do
      alice = fake_user!()
      lucy = fake_admin!()
      q = user_query()
      for conn <- [json_conn(), user_conn(alice), user_conn(lucy)] do
        user = gruff_post_key(q, conn, :user, %{user_id: alice.id})
        assert_user(alice, user)
      end
    end

  end

  describe "user.last_activity" do

    @tag :skip
    test "placeholder" do
    end

  end

  describe "user.my_follow" do

    test "is nil for a guest or a non-following user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      vars = %{user_id: bob.id}
      q = user_query(fields: [my_follow: follow_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(lucy)] do
        user = assert_user(bob, gruff_post_key(q, conn, :user, vars))
        assert user["myFollow"] == nil
      end
    end

    test "works for a following user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      vars = %{user_id: bob.id}
      q = user_query(fields: [my_follow: follow_fields()])
      for user <- [alice, lucy] do
        follow = follow!(user, bob)
        user2 = assert_user(bob, gruff_post_key(q, user_conn(user), :user, vars))
        assert_follow(follow, user2["myFollow"])
      end
    end

  end

  describe "user.my_like" do

    test "is nil for a guest or a non-liking user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      vars = %{user_id: bob.id}
      q = user_query(fields: [my_like: like_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(lucy)] do
        user = assert_user(bob, gruff_post_key(q, conn, :user, vars))
        assert user["myLike"] == nil
      end
    end

    test "works for a liking user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      vars = %{user_id: bob.id}
      q = user_query(fields: [my_like: like_fields()])
      for user <- [alice, lucy] do
        like = like!(user, bob)
        user2 = assert_user(bob, gruff_post_key(q, user_conn(user), :user, vars))
        assert_like(like, user2["myLike"])
      end
    end

  end

  describe "followed_communities" do

    test "works for anyone" do
      [alice, bob, eve] = some_fake_users!(%{}, 3)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      comm2 = fake_community!(bob)
      follows = Enum.map([comm, comm2], &follow!(eve, &1))
      q = user_query(fields: [followed_communities: page_fields(followed_community_fields())])
      vars = %{user_id: eve.id}
      conns = [user_conn(alice), user_conn(bob), user_conn(lucy), user_conn(eve), json_conn()]
      for conn <- conns do
        user = assert_user(eve, gruff_post_key(q, conn, :user, vars))
        follows2 = assert_page(user["followedCommunities"], 2, 2, false, false, &(&1["id"]))
        each(follows, follows2, &assert_follow/2)
      end
    end

  end

  describe "user.followed_collections" do
    @tag :skip
    test "placeholder" do
    end
  end

  describe "user.followed_users" do
    @tag :skip
    test "placeholder" do
    end
  end

  describe "user.likes" do

    @tag :skip # like_count view
    test "works for anyone for a public user" do
      [alice, bob, eve] = some_fake_users!(%{}, 3)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      some_randomer_likes!(23, coll)
      likes = Enum.map([comm, coll, bob], &like!(alice, &1))
      q = user_query(fields: [:like_count, likes: page_fields(like_fields())])
      vars = %{user_id: alice.id}
      conns = [user_conn(alice), user_conn(bob), user_conn(lucy), user_conn(eve), json_conn()]
      for conn <- conns do
        user = assert_user(alice, gruff_post_key(q, conn, :user, vars))
        likes2 = assert_page(user["likes"], 3, 3, false, true, &(&1["id"]))
        assert Enum.count(likes2) == 3
        piz(likes, likes2, &assert_like/2)
      end
    end

  end

  # describe "comments" do
  #   @tag :skip
  #   test "placeholder" do
  #   end
  # end

  # describe "inbox" do
  #   @tag :skip # broken
  #   test "Works for self" do
  #     alice = fake_user!()
  #     bob = fake_user!()
  #     comm = fake_community!(bob)
  #     conn = user_conn(alice)
  #     query = """
  #     { me {
  #         #{me_basics()}
  #         user {
  #           #{user_basics()}
  #           inbox { #{page_basics()} edges { #{activity_basics()} }
  #         }
  #       }
  #     }
  #     """
  #     assert %{"me" => me} = gql_post_data(conn, %{query: query})
  #     me = assert_me(me)
  #     assert %{"user" => user2} = me
  #     user2 = assert_user(alice, user2)
  #     assert %{"inbox" => inbox} = user2
  #     edges = assert_edges_page(inbox)
  #     assert Enum.count(edges.edges) == 1
  #     for edge <- edges.edges do
  #       activity = assert_activity(edge)
  #     end
  #   end
  #   # test "Does not work for other" do
  #   # end
  #   # test "Does not work for guest" do
  #   # end
  # end

  # describe "outbox" do

  #   test "Works for self" do
  #     user = fake_user!()
  #     conn = user_conn(user)
  #     query = """
  #     { me {
  #         #{me_basics()}
  #         user {
  #           #{user_basics()}
  #           outbox { #{page_basics()} edges { #{activity_basics()} } }
  #         }
  #       }
  #     }
  #     """
  #     assert %{"me" => me} = gql_post_data(conn, %{query: query})
  #     me = assert_me(me)
  #     assert %{"user" => user2} = me
  #     user2 = assert_user(user, user2)
  #     assert %{"outbox" => outbox} = user2
  #     edges = assert_edges_page(outbox)
  #     # assert Enum.count(edges.edges) == 5
  #     for edge <- edges.edges do
  #       activity = assert_activity(edge)
  #     end
  #   end
  # end


  ### mutations


  describe "create_user" do

    test "Works for a guest with good inputs" do
      reg = Fake.registration_input()
      assert {:ok, _} = Access.create_register_email(reg["email"])
      q = create_user_mutation()
      me = gruff_post_key(q, json_conn(), :create_user, %{user: reg})
      assert_me(reg, me)
    end

    test "Does not work for a logged in user" do
      alice = fake_user!()
      reg = Fake.registration_input()
      assert {:ok, _} = Access.create_register_email(reg["email"])
      q = create_user_mutation()
      assert_not_permitted(gruff_post_errors(q, user_conn(alice), %{user: reg}), ["createUser"])
    end

    @tag :skip # returns wrong format on error :/
    test "Does not work for a taken preferred username" do
      alice = fake_user!()
      reg = Fake.registration_input(%{"preferredUsername" => alice.actor.preferred_username})
      assert {:ok, _} = Access.create_register_email(reg["email"])
      q = create_user_mutation()
      gruff_post_errors(q, json_conn(), %{user: reg})
    end

    @tag :skip # returns wrong format on error :/
    test "Does not work for a taken email" do
      alice = fake_user!()
      reg = Fake.registration_input(%{"email" => alice.local_user.email})
      assert {:ok, _} = Access.create_register_email(reg["email"])
      q = create_user_mutation()
      gruff_post_errors(q, json_conn(), %{user: reg})
    end

  end

  describe "update_user" do

    test "Works for a logged in user" do
      alice = fake_user!()
      conn = user_conn(alice)
      profile = Fake.profile_update_input()
      q = update_profile_mutation()
      vars = %{profile: profile}
      me = gruff_post_key(q, conn, :update_profile, vars)
      assert_me(profile, me)
    end

    test "Does not work for a guest" do
      q = update_profile_mutation()
      vars = %{profile: Fake.profile_update_input()}
      assert_not_logged_in(gruff_post_errors(q, json_conn(), vars), ["updateProfile"])
    end

  end

  describe "delete_self" do

    test "Works for a logged in user" do
      alice = fake_user!()
      conn = user_conn(alice)
      q = delete_self_mutation()
      assert true == gruff_post_key(q, conn, :delete_self, %{i_am_sure: true})
    end

    test "Does not work if you are unsure" do
      alice = fake_user!()
      conn = user_conn(alice)
      q = delete_self_mutation()
      gruff_post_errors(q, conn)
    end

    test "Does not work for a guest" do
      q = delete_self_mutation()
      assert_not_logged_in(gruff_post_errors(q, json_conn(), %{i_am_sure: true}), ["deleteSelf"])
    end

  end

  describe "reset_password_request" do

    test "Works for a guest" do
      alice = fake_user!()
      q = reset_password_request_mutation()
      vars = %{email: alice.local_user.email}
      assert true == gruff_post_key(q, json_conn(), :reset_password_request, vars)
      # TODO: check that an email is sent
    end

    test "Does not work for a user" do
      alice = fake_user!()
      conn = user_conn(alice)
      q = reset_password_request_mutation()
      vars = %{email: alice.local_user.email}
      assert_not_permitted(gruff_post_errors(q, conn, vars), ["resetPasswordRequest"])
      # TODO: check that an email is not sent
    end

    test "Does not work for an invalid email" do
      q = reset_password_request_mutation()
      vars = %{email: Fake.email()}
      assert_not_found(gruff_post_errors(q, json_conn(), vars), ["resetPasswordRequest"])
    end

  end

  describe "reset_password" do

    test "Works for a guest with a valid token" do
      alice = fake_user!()
      assert {:ok, %{id: token}} = Users.request_password_reset(alice)
      q = reset_password_mutation()
      vars = %{token: token, password: "password"}
      auth = assert_auth_payload(gruff_post_key(q, json_conn(), :reset_password, vars))
      assert_me(alice, auth.me)
    end

    test "Does not work with a used token" do
      alice = fake_user!()
      assert {:ok, %{id: token}} = Users.request_password_reset(alice)
      q = reset_password_mutation()
      vars = %{token: token, password: "password"}
      auth = assert_auth_payload(gruff_post_key(q, json_conn(), :reset_password, vars))
      assert_me(alice, auth.me)
      gruff_post_errors(q, json_conn(), vars)
    end
    
    test "Does not work for a user" do
      alice = fake_user!()
      conn = user_conn(alice)
      assert {:ok, %{id: token}} = Users.request_password_reset(alice)
      q = reset_password_mutation()
      vars = %{token: token, password: "password"}
      assert_not_permitted(gruff_post_errors(q, conn, vars), ["resetPassword"])
    end

  end

  describe "confirm_email" do

    test "Works for a guest with a valid token" do
      alice = fake_user!()
      [token] = alice.local_user.email_confirm_tokens
      q = confirm_email_mutation()
      vars = %{token: token.id}
      conn = json_conn()
      auth = assert_auth_payload(gruff_post_key(q, conn, :confirm_email, vars))
      assert_me(alice, auth.me)
    end

    test "Does not work with an authenticated user" do
      alice = fake_user!()
      [token] = alice.local_user.email_confirm_tokens
      q = confirm_email_mutation()
      vars = %{token: token.id}
      conn = user_conn(alice)
      assert_not_permitted(gruff_post_errors(q, conn, vars), ["confirmEmail"])
    end

    test "Fails with an invalid token" do
      q = confirm_email_mutation()
      vars = %{token: Fake.uuid()}
      assert_not_found(gruff_post_errors(q, json_conn(), vars), ["confirmEmail"])
    end

  end

  describe "create_session" do

    test "Works with a valid email and password" do
      alice = fake_user!(%{password: "password"},confirm_email: true)
      q = create_session_mutation()
      vars = %{email: alice.local_user.email, password: "password"}
      auth = assert_auth_payload(gruff_post_key(q, json_conn(), :create_session, vars))
      assert_me(alice, auth.me)
    end

    test "Does not work with an unconfirmed email" do
      alice = fake_user!(%{password: "password"}, confirm_email: false)
      q = create_session_mutation()
      vars = %{email: alice.local_user.email, password: "password"}
      gruff_post_errors(q, json_conn(), vars)
    end

  end

  describe "delete_session" do

    test "Works with a logged in user" do
      user = fake_user!(%{password: "password"}, confirm_email: true)
      assert {:ok, token} = Access.create_token(user, "password")
      conn = token_conn(token)
      q = delete_session_mutation()
      assert true == gruff_post_key(q, conn, :delete_session)
    end

    test "Does not work for a guest" do
      q = delete_session_mutation()
      assert_not_logged_in(gruff_post_errors(q, json_conn()), ["deleteSession"])
    end

  end

end
