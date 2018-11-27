defmodule MoodleNetWeb.GraphQL.Schema.Community do
  use Absinthe.Schema.Notation

  object :community do
    field :id, :string
    field :local_id, :id
    field :local, :boolean
    field :type, list_of(:string)

    field :name, :json
    field :content, :json
    field :summary, :json

    field :preferred_username, :string


    field :following_count, :integer
    field :followers_count, :integer

    # field :memberships, list_of(Relationship)
    # field :otherRelationships, list_of(Relationship) # any profile relation that isn't of type following, followers, or group membership

    field :json_data, :json

    field :icon, :string
    # field :following, list_of(Profile)
    # field :followers, list_of(Profile)
    # field :feed, list_of(Activity) # latest activities FOR this profile (i.e. feed of all activities by profiles they're following)
    # field :activities, list_of(:activity) # latest activities BY this profile

    field :primary_language, :string

    field :collections_count, :integer
    field :collections, list_of(:collection)
    field :comments, list_of(:comment)
  end

  object :collection do
    field :id, :string
    field :local_id, :id
    field :local, :boolean
    field :type, list_of(:string)

    field :name, :json
    field :content, :json
    field :summary, :json

    field :preferred_username, :string

    field :following_count, :integer
    field :followers_count, :integer

    # field :memberships, list_of(Relationship)
    # field :otherRelationships, list_of(Relationship) # any profile relation that isn't of type following, followers, or group membership

    field :json_data, :json

    field :icon, :string
    # field :following, list_of(Profile)
    # field :followers, list_of(Profile)
    # field :feed, list_of(Activity) # latest activities FOR this profile (i.e. feed of all activities by profiles they're following)
    # field :activities, list_of(:activity) # latest activities BY this profile

    field :primary_language, :string
    field :resources_count, :integer

    field :resources, list_of(:resource)
    field :comments, list_of(:comment)
    field :context, :community
  end

  object :resource do
    field :id, :string
    field :local_id, :id
    field :local, :boolean
    field :type, list_of(:string)

    field :name, :json
    field :content, :json
    field :summary, :json

    field :preferred_username, :string

    field :following_count, :integer
    field :followers_count, :integer

    # field :memberships, list_of(Relationship)
    # field :otherRelationships, list_of(Relationship) # any profile relation that isn't of type following, followers, or group membership

    field :json_data, :json

    field :icon, :string
    # field :following, list_of(Profile)
    # field :followers, list_of(Profile)
    # field :feed, list_of(Activity) # latest activities FOR this profile (i.e. feed of all activities by profiles they're following)
    # field :activities, list_of(:activity) # latest activities BY this profile

    field :primary_language, :string
    field :likes_count, :integer
    field :url, :string
    field :context, :collection
  end

  object :comment do
    field :id, :string
    field :local_id, :id
    field :local, :boolean
    field :type, list_of(:string)

    field :content, :json
    field :likes_count, :integer
    field :primary_language, :string
    field :published, :string

    field :author, :user
    field :in_reply_to, :comment
    field :replies, list_of(:comment)
  end
end
