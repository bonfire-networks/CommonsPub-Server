defmodule MoodleNetWeb.Test.GraphQLFields do

  def page_basics() do
    "totalCount pageInfo { startCursor endCursor hasPreviousPage hasNextPage __typename }"
  end
  
  def user_basics() do
    """
    id canonicalUrl preferredUsername displayUsername
    name summary location website icon image followerCount likerCount
    isLocal isPublic isDisabled createdAt updatedAt __typename
    """
  end

  def me_basics() do
    """
    email wantsEmailDigest wantsNotifications isConfirmed isInstanceAdmin __typename
    """
  end

  def thread_basics() do
    """
    id canonicalUrl followerCount
    isLocal isPublic isHidden createdAt updatedAt __typename
    """
  end

  def comment_basics() do
    """
    id canonicalUrl content likerCount
    isLocal isPublic isHidden createdAt updatedAt __typename
    """
  end

  def community_basics() do
    """
    id canonicalUrl preferredUsername displayUsername
    name summary icon image collectionCount followerCount likerCount
    isLocal isPublic isDisabled createdAt updatedAt __typename
    """
  end

  def collection_basics() do
    """
    id canonicalUrl preferredUsername displayUsername
    name summary icon resourceCount followerCount likerCount
    isLocal isPublic isDisabled createdAt updatedAt __typename
    """
  end

  def resource_basics() do
    """
    id canonicalUrl
    name summary icon url license
    isLocal isPublic isDisabled createdAt updatedAt __typename
    """
  end

  def flag_basics() do
    """
    id canonicalUrl message isResolved
    isLocal createdAt updatedAt __typename
    """
  end

  def like_basics() do
    """
    id canonicalUrl
    isLocal isPublic createdAt updatedAt __typename
    """
  end

  def follow_basics() do
    """
    id canonicalUrl
    isLocal isPublic createdAt updatedAt __typename
    """
  end

  def tag_category_basics() do
    """
    id canonicalUrl name
    isLocal isPublic createdAt __typename
    """
  end

  def tag_basics() do
    """
    id canonicalUrl name
    isLocal isPublic createdAt __typename
    """
  end

  def tagging_basics() do
    """
    id canonicalUrl
    isLocal isPublic createdAt __typename
    """
  end

  def activity_basics() do
    """
    id canonicalUrl verb
    isLocal isPublic createdAt __typename
    """
  end

  def language_basics() do
    """
    id isoCode2 isoCode3 englishName localName createdAt updatedAt __typename
    """
  end

  def country_basics() do
    """
    id isoCode2 isoCode3 englishName localName createdAt updatedAt __typename
    """
  end

  def feature_basics() do
    """
    id canonicalUrl isLocal createdAt __typename
    """
  end
end
