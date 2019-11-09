# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UsersSchema do
  @moduledoc """
  GraphQL user fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver,UsersResolver}

  object :users_queries do

    @desc "Get my user"
    field :me, type: :me do
      resolve &UsersResolver.me/2
    end

    @desc "Get an user"
    field :user, type: :user do
      arg :user_id, non_null(:string)
      resolve &UsersResolver.user/2
    end

    @desc "Check if a user exists with a username"
    field :username_available, type: :boolean do
      arg :username, non_null(:string)
      resolve &UsersResolver.check_username_available/2
    end

    # TODO
    field :user_inbox, type: :boolean do
      arg :limit, :integer
      arg :before, :integer
      arg :after, :integer
      resolve &UsersResolver.inbox/2
    end
  end

  object :users_mutations do

    @desc "Create a user"
    field :create_user, type: :me do
      arg :user, non_null(:registration_input)
      resolve &UsersResolver.create/2
    end

    @desc "Update a profile"
    field :update_profile, type: :me do
      arg :profile, non_null(:update_profile_input)
      resolve &UsersResolver.update_profile/2
    end

    @desc "Delete a user"
    field :delete_user, type: :boolean do
      resolve &UsersResolver.delete/2
    end

    @desc "Reset password request"
    field :reset_password_request, type: :boolean do
      arg :email, non_null(:string)
      resolve &UsersResolver.reset_password_request/2
    end

    @desc "Reset password"
    field :reset_password, type: :boolean do
      arg :token, non_null(:string)
      arg :password, non_null(:string)
      resolve &UsersResolver.reset_password/2
    end

    @desc "Confirm email. Returns a login token."
    field :confirm_email, type: :string do
      arg :token, non_null(:string)
      resolve &UsersResolver.confirm_email/2
    end

    @desc "Log in"
    field :create_session, type: :auth_payload do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &UsersResolver.create_session/2
    end

    @desc "Log out"
    field :delete_session, type: :boolean do
      resolve &UsersResolver.delete_session/2
    end
  end

  @desc """
  The current user. Contains more information than just the `user` type
  """
  object :me do
    @desc "The public info"
    field :user, :user
    @desc "The user's email"
    field :email, :string
    @desc "Would the user like to receive digest emails of updates?"
    field :wants_email_digest, :bool
    @desc "Does the user want notifications? Which don't work yet."
    field :wants_notifications, :bool
    @desc "Has the user confirmed their account?"
    field :is_confirmed, :bool
    @desc "Is the user a witch or wizard?"
    field :is_instance_admin, :bool
  end

  @desc "User profile information"
  object :user do
    @desc "An instance-local UUID identifying the user"
    field :id, :id
    @desc "A url for the user, may be to a remote instance"
    field :canonical_url, :string
    @desc "An instance-unique identifier shared with communities and collections"
    field :preferred_username, :string

    @desc "A name field"
    field :name, :string
    @desc "Possibly biographical information"
    field :summary, :string
    @desc "An avatar url"
    field :icon, :string
    @desc "A header background image url"
    field :image, :string
    @desc "Free text"
    field :location, :string
    @desc "A valid URL"
    field :website, :string

    @desc "Whether the user is local to the instance"
    field :is_local, :boolean
    @desc "Whether the user has a public profile"
    field :is_public, :boolean
    @desc "Whether an instance admin has disabled the user's account"
    field :is_disabled, :boolean

    @desc "When the user signed up"
    field :created_at, :string
    @desc "When the user last updated their profile"
    field :updated_at, :string
    @desc "The last time the user did anything"
    field :last_activity, :string

    @desc "The language the user wishes to use moodlenet in"
    field :primary_language, :language do
      resolve &CommonResolver.primary_language/3
    end

    @desc "The current user's follow of this user, if any"
    field :my_follow, :follow do
      resolve &CommonResolver.my_follow/3
    end

    @desc "The current user's like of this user, if any"
    field :my_like, like do
      resolve &CommonResolver.my_like/3
    end

    @desc "The communities a user has joined, most recently joined first"
    field :joined_communities, :user_joined_communities_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &UsersResolver.joined_communities/3
    end

    @desc "The collections a user is following, most recently followed first"
    field :following_collections, :user_following_collections_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &UsersResolver.following_collections/3
    end

    @desc "Comments the user has made, most recently created first"
    field :comments, :user_created_comments_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &UsersResolver.comments/3
    end

    @desc "Activities of the user, most recently created first"
    field :outbox, :user_outbox_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &UsersResolver.outbox/3
    end

    @desc """
    Activities of others the user is following, most recently created
    first. Only available to the current user under `me`
    """
    field :inbox, :user_inbox_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &UsersResolver.inbox/3
    end

    @desc "Tags users have applied to the resource, most recently created first"
    field :tags, non_null(:resource_flags_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.tags/3
    end

  end

  object :user_joined_communities_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:user_joined_communities_edge)
    field :total_count, non_null(:integer)
  end

  object :user_joined_communities_edge do
    field :cursor, non_null(:string)
    field :node, :community
  end

  object :user_following_collections_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:user_following_collections_edge)
    field :total_count, non_null(:integer)
  end

  object :user_following_collections_edge do
    field :cursor, non_null(:string)
    field :node, :collection
  end

  object :user_created_comments_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:user_created_comments_edge)
    field :total_count, non_null(:integer)
  end

  object :user_inbox_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:user_activities_edge)
    field :total_count, non_null(:integer)
  end

  object :user_outbox_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:user_activities_edge)
    field :total_count, non_null(:integer)
  end

  object :user_activities_edge do
    field :cursor, non_null(:string)
    field :node, :activity
  end

  object :user_created_comments_edge do
    field :cursor, non_null(:string)
    field :node, :comment
  end

  input_object :registration_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
    field :preferred_username, non_null(:string)
    field :name, :string
    field :summary, :string
    field :icon, :string
    field :image, :string
    field :location, :string
    field :website, :string
    field :primary_language_id, :string
    # field :is_public, non_null(:boolean)
    field :wants_email_digest, :boolean
    field :wants_notifications, :boolean
  end

  input_object :update_profile_input do
    field :preferred_username, :string
    field :name, :string
    field :summary, :string
    field :icon, :string
    field :image, :string
    field :location, :string
    field :website, :string
    field :primary_language_id, :string
    field :wants_email_digest, :boolean
    field :wants_notifications, :boolean
  end

  input_object :login_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
  end

end
