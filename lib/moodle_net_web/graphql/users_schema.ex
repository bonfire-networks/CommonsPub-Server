# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UsersSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{
    CollectionsResolver,
    CommonResolver,
    CommentsResolver,
    CommunitiesResolver,
    LocalisationResolver,
    UsersResolver,
  }

  object :users_queries do

    @desc "Check if a user exists with a username"
    field :username_available, non_null(:boolean) do
      arg :username, non_null(:string)
      resolve &UsersResolver.username_available/2
    end

    @desc "Get my user"
    field :me, :me do
      resolve &UsersResolver.me/2
    end

    @desc "Get an user"
    field :user, :user do
      arg :user_id, non_null(:string)
      resolve &UsersResolver.user/2
    end

  end

  object :auth_payload do
    field :token, non_null(:string)
    field :me, non_null(:me)
  end

  object :users_mutations do

    @desc "Create a user"
    field :create_user, :me do
      arg :user, non_null(:registration_input)
      resolve &UsersResolver.create_user/2
    end

    @desc "Update a profile"
    field :update_profile, :me do
      arg :profile, non_null(:update_profile_input)
      resolve &UsersResolver.update_profile/2
    end

    @desc "Reset password request"
    field :reset_password_request, :boolean do
      arg :email, non_null(:string)
      resolve &UsersResolver.reset_password_request/2
    end

    @desc "Reset password"
    field :reset_password, :auth_payload do
      arg :token, non_null(:string)
      arg :password, non_null(:string)
      resolve &UsersResolver.reset_password/2
    end

    @desc "Confirm email. Returns a login token."
    field :confirm_email, :auth_payload do
      arg :token, non_null(:string)
      resolve &UsersResolver.confirm_email/2
    end

    @desc "Log in"
    field :create_session, :auth_payload do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &UsersResolver.create_session/2
    end

    @desc "Log out"
    field :delete_session, :boolean do
      resolve &UsersResolver.delete_session/2
    end

    @desc "Deletes my account!"
    field :delete_self, :boolean do
      arg :i_am_sure, non_null(:boolean)
      resolve &UsersResolver.delete/2
    end

  end

  @desc """
  The current user. Contains more information than just the `user` type
  """
  object :me do
    @desc "The public info"
    field :user, non_null(:user)
    @desc "The user's email"
    field :email, non_null(:string)
    @desc "Would the user like to receive digest emails of updates?"
    field :wants_email_digest, non_null(:boolean)
    @desc "Does the user want notifications? Which don't work yet."
    field :wants_notifications, non_null(:boolean)
    @desc "Has the user confirmed their account?"
    field :is_confirmed, non_null(:boolean)
    @desc "Is the user a witch or wizard?"
    field :is_instance_admin, non_null(:boolean)
  end

  @desc "User profile information"
  object :user do
    @desc "An instance-local UUID identifying the user"
    field :id, non_null(:id)
    @desc "A url for the user, may be to a remote instance"
    field :canonical_url, :string
    @desc "An instance-unique identifier shared with communities and collections"
    field :preferred_username, non_null(:string)

    @desc "A name field"
    field :name, non_null(:string)
    @desc "Possibly biographical information"
    field :summary, :string
    @desc "Free text"
    field :location, :string
    @desc "A valid URL"
    field :website, :string
    @desc "An avatar url"
    field :icon, :string
    @desc "A header background image url"
    field :image, :string

    @desc "Whether the user is local to the instance"
    field :is_local, non_null(:boolean)
    @desc "Whether the user has a public profile"
    field :is_public, non_null(:boolean)
    @desc "Whether an instance admin has disabled the user's account"
    field :is_disabled, non_null(:boolean)

    @desc "When the user signed up"
    field :created_at, non_null(:string)
    @desc "When the user last updated their profile"
    field :updated_at, non_null(:string)
    @desc "The last time the user did anything"
    field :last_activity, non_null(:string) do
      resolve &UsersResolver.last_activity/3
    end

    @desc "The current user's follow of this user, if any"
    field :my_follow, :follow do
      resolve &CommonResolver.my_follow/3
    end

    @desc "The current user's like of this user, if any"
    field :my_like, :like do
      resolve &CommonResolver.my_like/3
    end

    # @desc "The language the user wishes to use moodlenet in"
    # field :primary_language, :language do
    #   resolve &LocalisationResolver.primary_language/3
    # end

    @desc "The communities a user is following, most recently followed first"
    field :followed_communities, non_null(:followed_communities_edges) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &UsersResolver.followed_communities/3
    end

    @desc "The collections a user is following, most recently followed first"
    field :followed_collections, non_null(:followed_collections_edges) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &UsersResolver.followed_collections/3
    end

    @desc "The users a user is following, most recently followed first"
    field :followed_users, non_null(:followed_users_edges) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &UsersResolver.followed_users/3
    end

    @desc "The collections a user is following, most recently followed first"
    field :likes, non_null(:likes_edges) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.likes/3
    end

    @desc "Comments the user has made, most recently created first"
    field :comments, non_null(:comments_edges) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommentsResolver.comments/3
    end

    @desc "Activities of the user, most recently created first"
    field :outbox, non_null(:activities_edges) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &UsersResolver.outbox/3
    end

    @desc """
    Activities of others the user is following, most recently created
    first. Only available to the current user under `me`
    """
    field :inbox, non_null(:activities_edges) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &UsersResolver.inbox/3
    end

  #   @desc "Taggings the user has created"
  #   field :tagged, :taggings_edges do
  #     arg :limit, :integer
  #     arg :before, :string
  #     arg :after, :string
  #     resolve &CommonResolver.tagged/3
  #   end

  end

  object :followed_community do
    field :follow, non_null(:follow) do
      resolve &CommonResolver.follow/3
    end
    field :community, non_null(:community) do
      resolve &CommunitiesResolver.community/3
    end
  end

  object :followed_communities_edges do
    field :page_info, :page_info
    field :edges, non_null(list_of(:followed_communities_edge))
    field :total_count, non_null(:integer)
  end

  object :followed_communities_edge do
    field :cursor, non_null(:string)
    field :node, non_null(:followed_community)
  end

  object :followed_collection do
    field :follow, non_null(:follow) do
      resolve &CommonResolver.follow/3
    end
    field :collection, non_null(:collection) do
      resolve &CollectionsResolver.collection/3
    end
  end

  object :followed_collections_edges do
    field :page_info, :page_info
    field :edges, non_null(list_of(:followed_collections_edge))
    field :total_count, non_null(:integer)
  end

  object :followed_collections_edge do
    field :cursor, non_null(:string)
    field :node, non_null(:followed_collection)
  end

  object :followed_user do
    field :follow, non_null(:follow) do
      resolve &CommonResolver.follow/3
    end
    field :user, non_null(:user) do
      resolve &UsersResolver.user/3
    end
  end

  object :followed_users_edges do
    field :page_info, :page_info
    field :edges, non_null(list_of(:followed_users_edge))
    field :total_count, non_null(:integer)
  end

  object :followed_users_edge do
    field :cursor, non_null(:string)
    field :node, non_null(:followed_user)
  end

  input_object :registration_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
    field :preferred_username, non_null(:string)
    field :name, non_null(:string)
    field :summary, :string
    field :location, :string
    field :website, :string
    field :icon, :string
    field :image, :string
    # field :primary_language_id, :string
    field :wants_email_digest, non_null(:boolean)
    field :wants_notifications, non_null(:boolean)
  end

  input_object :update_profile_input do
    field :name, :string
    field :summary, :string
    field :location, :string
    field :website, :string
    field :icon, :string
    field :image, :string
    # field :primary_language_id, :string
    field :wants_email_digest, :boolean
    field :wants_notifications, :boolean
  end

  input_object :login_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
  end

end
