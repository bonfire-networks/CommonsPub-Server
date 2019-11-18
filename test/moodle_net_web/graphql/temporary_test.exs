# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.TemporaryTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLAssertions
  # import MoodleNet.Test.Faking
  # import MoodleNetWeb.Test.ConnHelpers
  # alias MoodleNet.Test.Fake
  # alias MoodleNet.{Actors, OAuth, Users, Access}

  # @page_basics "totalCount pageInfo { startCursor endCursor __typename }"
  # @user_basics """
  # id canonicalUrl preferredUsername
  # name summary location website icon image
  # isLocal isPublic isDisabled createdAt updatedAt __typename
  # """
  # @me_basics """
  # email wantsEmailDigest wantsNotifications isConfirmed isInstanceAdmin __typename
  # """
  # @thread_basics  """
  # id canonicalUrl
  # isLocal isPublic isHidden createdAt updatedAt __typename
  # """
  # @comment_basics """
  # id canonicalUrl content
  # isLocal isPublic isHidden createdAt updatedAt __typename
  # """
  # @community_basics """
  # id canonicalUrl preferredUsername
  # name summary icon image
  # isLocal isPublic isDisabled createdAt updatedAt __typename
  # """
  # @collection_basics """
  # id canonicalUrl preferredUsername
  # name summary icon
  # isLocal isPublic isDisabled createdAt updatedAt __typename
  # """
  # @resource_basics """
  # id canonicalUrl
  # name summary icon url license
  # isLocal isPublic isDisabled createdAt updatedAt __typename
  # """
  # @flag_basics """
  # id canonicalUrl message isResolved
  # isLocal isPublic createdAt updatedAt __typename
  # """
  # @like_basics """
  # id canonicalUrl
  # isLocal isPublic createdAt updatedAt __typename
  # """
  # @follow_basics """
  # id canonicalUrl
  # isLocal isPublic createdAt updatedAt __typename
  # """
  # # @tag_category_basics """
  # # id canonicalUrl name
  # # isLocal isPublic createdAt __typename
  # # """
  # # @tag_basics """
  # # id canonicalUrl name
  # # isLocal isPublic createdAt __typename
  # # """
  # # @tagging_basics """
  # # id canonicalUrl
  # # isLocal isPublic createdAt __typename
  # # """
  # @activity_basics """
  # id canonicalUrl verb
  # isLocal isPublic createdAt __typename
  # """
  # @language_basics """
  # id isoCode2 isoCode3 englishName localName createdAt updatedAt __typename
  # """
  # @country_basics """
  # id isoCode2 isoCode3 englishName localName createdAt updatedAt __typename
  # """
  # # activity schema

  # test "activity" do
  #   q = """
  #   query Test {
  #     activity(activityId: "") { #{@activity_basics} }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"activity" => act} = gql_post_data(json_conn(), query)
  #   assert_activity(act)
  # end

  # test "activity.user" do
  #   q = """
  #   query Test {
  #     activity(activityId: "") {
  #       #{@activity_basics}
  #       user { #{@user_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"activity" => act} = gql_post_data(json_conn(), query)
  #   assert %{"user" => user} = act
  #   assert_activity(act)
  #   assert_user(user)
  # end

  # test "activity.context" do
  #   for _ <- 1..30 do
  #     q = """
  #     query Test {
  #       activity(activityId: "") {
  #         #{@activity_basics}
  #         context {
  #           ... on Collection { #{@collection_basics} }
  #           ... on Comment { #{@comment_basics} }
  #           ... on Community { #{@community_basics} }
  #           ... on Resource { #{@resource_basics} }
  #         }
  #       }
  #     }
  #     """
  #     query = %{query: q, operation_name: "Test"}
  #     assert %{"activity" => act} = gql_post_data(json_conn(), query)
  #     assert %{"context" => context} = act
  #     assert_activity(act)
  #     assert_activity_context(context)
  #   end
  # end

  # # admin schema

  # test "resolve_flag" do
  #   q = """
  #   mutation Test {
  #     resolveFlag(flagId: "") { #{@flag_basics} }
  #   }
  #   """
  #   assert %{"resolveFlag" => flag} =
  #     gql_post_data(json_conn(), %{query: q, operation_name: "Test"})
  #   assert_flag(flag)
  # end

  # # collections schema

  # test "collections" do
  #   q = """
  #   query Test {
  #     collections {
  #       #{@page_basics}
  #       nodes { #{@collection_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"collections" => page} = gql_post_data(json_conn(), query)
  #   colls = assert_node_list(page)
  #   for c <- colls, do: assert_collection(c)
  # end

  # test "collection" do
  #   q = """
  #   query Test {
  #     collection(collectionId: "") {
  #       #{@collection_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  #   assert_collection(coll)
  # end

  # test "create_collection" do
  #   vars = %{"collection" => Fake.collection_input()}
  #   q = """
  #   mutation Test($collection: CollectionInput!) {
  #     createCollection(collection: $collection, communityId: "") {
  #       #{@collection_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test", variables: vars}
  #   assert %{"createCollection" => coll} = gql_post_data(json_conn(), query)
  #   assert_collection(coll)
  # end

  # test "update_collection" do
  #   vars = %{"collection" => Fake.collection_input()}
  #   q = """
  #   mutation Test($collection: CollectionInput!) {
  #     updateCollection(collection: $collection, collectionId: "") {
  #       #{@collection_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test", variables: vars}
  #   assert %{"updateCollection" => coll} = gql_post_data(json_conn(), query)
  #   assert_collection(coll)
  # end

  # test "collection.last_activity" do
  #   q = """
  #   query Test {
  #     collection(collectionId: "") {
  #       #{@collection_basics}
  #       lastActivity
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  #   assert %{"lastActivity" => act} = coll
  #   assert_collection(coll)
  #   assert is_binary(act)
  # end

  # test "collection.my_like" do
  #   q = """
  #   query Test {
  #     collection(collectionId: "") {
  #       myLike { #{@like_basics} }
  #       #{@collection_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"collection" => collection} = gql_post_data(json_conn(), query)
  #   assert %{"myLike" => like} = collection
  #   assert_collection(collection)
  #   assert_like(like)
  # end

  # test "collection.my_follow" do
  #   q = """
  #   query Test {
  #     collection(collectionId: "") {
  #       #{@collection_basics}
  #       myFollow { #{@follow_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  #   assert %{"myFollow" => follow} = coll
  #   assert_follow(follow)
  # end

  # # test "collection.primary_language" do
  # #   q = """
  # #   query Test {
  # #     collection(collectionId: "") {
  # #       #{@collection_basics}
  # #       primaryLanguage { #{@language_basics} }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operation_name: "Test"}
  # #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  # #   assert %{"primaryLanguage" => lang} = coll
  # #   assert_collection(coll)
  # #   assert_language(lang)
  # # end

  # test "collection.creator" do
  #   q = """
  #   query Test {
  #     collection(collectionId: "") {
  #       #{@collection_basics}
  #       creator { #{@user_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  #   assert %{"creator" => user} = coll
  #   assert_collection(coll)
  #   assert_user(user)
  # end

  # test "collection.community" do
  #   q = """
  #   query Test {
  #     collection(collectionId: "") {
  #       #{@collection_basics}
  #       community { #{@community_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  #   assert %{"community" => comm} = coll
  #   assert_collection(coll)
  #   assert_community(comm)
  # end

  # test "collection.resources" do
  #   q = """
  #   query Test {
  #     collection(collectionId: "") {
  #       #{@collection_basics}
  #       resources {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@resource_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  #   assert_collection(coll)
  #   assert %{"resources" => res} = coll
  #   for node <- assert_edge_list(res) do
  #     assert_resource(node)
  #   end
  # end

  # test "collection.followers" do
  #   q = """
  #   query Test {
  #     collection(collectionId: "") {
  #       #{@collection_basics}
  #       followers {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@follow_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  #   assert_collection(coll)
  #   assert %{"followers" => foll} = coll
  #   for node <- assert_edge_list(foll) do
  #     assert_follow(node)
  #   end
  # end

  # test "collection.likes" do
  #   q = """
  #   query Test {
  #     collection(collectionId: "") {
  #       #{@collection_basics}
  #       likes {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@like_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  #   assert_collection(coll)
  #   assert %{"likes" => likes} = coll
  #   for node <- assert_edge_list(likes) do
  #     assert_like(node)
  #   end
  # end

  # test "collection.flags" do
  #   q = """
  #   query Test {
  #     collection(collectionId: "") {
  #       #{@collection_basics}
  #       flags {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@flag_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  #   assert_collection(coll)
  #   assert %{"flags" => flags} = coll
  #   for node <- assert_edge_list(flags) do
  #     assert_flag(node)
  #   end
  # end
 
  # # test "collection.tags" do
  # #   q = """
  # #   query Test {
  # #     collection(collectionId: "") {
  # #       #{@collection_basics}
  # #       tags {
  # #         #{@page_basics}
  # #         edges {
  # #           cursor
  # #           node { #{@tagging_basics} }
  # #         }
  # #       }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operation_name: "Test"}
  # #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  # #   assert_collection(coll)
  # #   assert %{"tags" => tags} = coll
  # #   for node <- assert_edge_list(tags) do
  # #     assert_tagging(node)
  # #   end
  # # end

  # test "collection.threads" do
  #   q = """
  #   query Test {
  #     collection(collectionId: "") {
  #       #{@collection_basics}
  #       threads {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@thread_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  #   assert_collection(coll)
  #   assert %{"threads" => threads} = coll
  #   for node <- assert_edge_list(threads) do
  #     assert_thread(node)
  #   end
  # end

  # test "collection.outbox" do
  #   q = """
  #   query Test {
  #     collection(collectionId: "") {
  #       #{@collection_basics}
  #       outbox {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@activity_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"collection" => coll} = gql_post_data(json_conn(), query)
  #   assert_collection(coll)
  #   assert %{"outbox" => outbox} = coll
  #   for node <- assert_edge_list(outbox) do
  #     assert_activity(node)
  #   end
  # end

  # # comments schema

  # test "thread" do
  #   q = """
  #   query Test {
  #     thread(threadId: "") {
  #       #{@thread_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"thread" => thread} = gql_post_data(json_conn(), query)
  #   assert_thread(thread)
  # end

  # test "comment" do
  #   q = """
  #   query Test {
  #     comment(commentId: "") { #{@comment_basics} }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"comment" => comment} = gql_post_data(json_conn(), query)
  #   assert_comment(comment)
  # end

  # test "create_thread" do
  #   vars = %{"comment" => Fake.comment_input()}
  #   q = """
  #   mutation Test($comment: CommentInput!) {
  #     createThread(comment: $comment, contextId: "") {
  #       #{@comment_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test", variables: vars}
  #   assert %{"createThread" => comment} = gql_post_data(json_conn(), query)
  #   assert_comment(comment)
  # end

  # test "create_reply" do
  #   vars = %{"comment" => Fake.comment_input()}
  #   q = """
  #   mutation Test($comment: CommentInput!) {
  #     createReply(threadId: "", inReplyToId: "", comment: $comment) {
  #       #{@comment_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test", variables: vars}
  #   assert %{"createReply" => comment} = gql_post_data(json_conn(), query)
  #   assert_comment(comment)
  # end

  # test "editComment" do # comment
  #   vars = %{"comment" => Fake.comment_input()}
  #   q = """
  #   mutation Test($comment: CommentInput!) {
  #     editComment(commentId: "", comment: $comment) {
  #       #{@comment_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test", variables: vars}
  #   assert %{"editComment" => comment} = gql_post_data(json_conn(), query)
  #   assert_comment(comment)
  # end

  # test "thread.last_activity" do
  #   q = """
  #   query Test {
  #     thread(threadId: "") {
  #       #{@thread_basics}
  #       lastActivity
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"thread" => thread} = gql_post_data(json_conn(), query)
  #   assert %{"lastActivity" => act} = thread
  #   assert_thread(thread)
  #   assert is_binary(act)
  # end

  # test "thread.my_follow" do
  #   q = """
  #   query Test {
  #     thread(threadId: "") {
  #       myFollow { #{@follow_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"thread" => thread} = gql_post_data(json_conn(), query)
  #   assert %{"myFollow" => follow} = thread
  #   assert_follow(follow)
  # end

  # test "thread.context" do
  #   q = """
  #   query Test {
  #     thread(threadId: "") {
  #       #{@thread_basics}
  #       context {
  #         __typename
  #         ... on Collection { #{@collection_basics} }
  #         ... on Community  { #{@community_basics} }
  #         ... on Flag       { #{@flag_basics} }
  #         ... on Resource   { #{@resource_basics} }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operation_name: "Test"}
  #   assert %{"thread" => thread} = gql_post_data(json_conn(), query)
  #   assert %{"context" => context} = thread
  #   assert_thread(thread)
  #   assert_thread_context(context)
  # end

  # test "thread.comments" do
  #   q = """
  #   query Test {
  #     thread(threadId: "") {
  #       comments {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@comment_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"thread" => thread} = gql_post_data(json_conn(), query)
  #   assert %{"comments" => comments} = thread
  #   for comment <- assert_edge_list(comments), do: assert_comment(comment)
  # end

  # test "thread.followers" do
  #   q = """
  #   query Test {
  #     thread(threadId: "") {
  #       followers {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@follow_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"thread" => thread} = gql_post_data(json_conn(), query)
  #   assert %{"followers" => follows} = thread
  #   for follow <- assert_edge_list(follows), do: assert_follow(follow)
  # end

  # test "comment.my_like" do
  #   q = """
  #   query Test {
  #     comment(commentId: "") {
  #       myLike { #{@like_basics} }
  #       #{@comment_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"comment" => comment} = gql_post_data(json_conn(), query)
  #   assert %{"myLike" => like} = comment
  #   assert_comment(comment)
  #   assert_like(like)
  # end

  # test "comment.creator" do
  #   q = """
  #   query Test {
  #     comment(commentId: "") {
  #       creator { #{@user_basics} }
  #       #{@comment_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"comment" => comment} = gql_post_data(json_conn(), query)
  #   assert %{"creator" => user} = comment
  #   assert_comment(comment)
  #   assert_user(user)
  # end

  # test "comment.thread" do
  #   q = """
  #   query Test {
  #     comment(commentId: "") {
  #       thread { #{@thread_basics} }
  #       #{@comment_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"comment" => comment} = gql_post_data(json_conn(), query)
  #   assert %{"thread" => thread} = comment
  #   assert_comment(comment)
  #   assert_thread(thread)
  # end

  # test "comment.likes" do
  #   q = """
  #   query Test {
  #     comment(commentId: "") {
  #       #{@comment_basics}
  #       likes {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@like_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"comment" => comment} = gql_post_data(json_conn(), query)
  #   assert %{"likes" => likes} = comment
  #   assert_comment(comment)
  #   for like <- assert_edge_list(likes), do: assert_like(like)
  # end

  # test "comment.flags" do
  #   q = """
  #   query Test {
  #     comment(commentId: "") {
  #       #{@comment_basics}
  #       flags {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@flag_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"comment" => comment} = gql_post_data(json_conn(), query)
  #   assert %{"flags" => flags} = comment
  #   assert_comment(comment)
  #   for flag <- assert_edge_list(flags), do: assert_flag(flag)
  # end

  # # common schema

  # test "create_follow" do
  #   q = """
  #   mutation Test {
  #     createFollow(contextId: "") {
  #       #{@follow_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"createFollow" => follow} = gql_post_data(json_conn(), query)
  #   assert_follow(follow)
  # end

  # test "create_flag" do
  #   q = """
  #   mutation Test {
  #     createFlag(contextId: "", message: "") {
  #       #{@flag_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"createFlag" => flag} = gql_post_data(json_conn(), query)
  #   assert_flag(flag)
  # end

  # test "create_like" do
  #   q = """
  #   mutation Test {
  #     createLike(contextId: "") {
  #       #{@like_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"createLike" => like} = gql_post_data(json_conn(), query)
  #   assert_like(like)
  # end

  # # @tag :skip
  # # test "tag_category" do
  # #   q = """
  # #   query Test {
  # #     tagCategory(tagCategoryId: "") { #{@tag_category_basics} }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"tagCategory" => cat} = gql_post_data(json_conn(), query)
  # #   assert_tag_category(cat)
  # # end

  # # @tag :skip
  # # test "tag" do
  # #   q = """
  # #   query Test {
  # #     tagCategory(tagCategoryId: "") { #{@tag_category_basics} }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"tag" => tag} = gql_post_data(json_conn(), query)
  # #   assert_tag(tag)
  # # end

  # test "follow" do
  #   q = """
  #   query Test {
  #     follow(followId: "") {
  #       #{@follow_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"follow" => follow} = gql_post_data(json_conn(), query)
  #   assert_follow(follow)
  # end

  # test "follow.context" do
  #   for _ <- 1..30 do
  #     q = """
  #     query Test {
  #       follow(followId: "") {
  #         #{@follow_basics}
  #         context {
  #           __typename
  #           ... on Collection { #{@collection_basics} }
  #           ... on Community  { #{@community_basics} }
  #           ... on Thread     { #{@thread_basics} }
  #           ... on User       { #{@user_basics} }
  #         }
  #       }
  #     }
  #     """
  #     query = %{query: q, operationName: "Test"}
  #     assert %{"follow" => follow} = gql_post_data(json_conn(), query)
  #     assert_follow(follow)
  #     assert %{"context" => context} = follow
  #     assert_follow_context(context)
  #   end
  # end

  # test "flag" do
  #   q = """
  #   query Test {
  #     flag(flagId: "") {
  #       #{@flag_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"flag" => flag} = gql_post_data(json_conn(), query)
  #   assert_flag(flag)
  # end

  # test "flag.creator" do
  #   q = """
  #   query Test {
  #     flag(flagId: "") {
  #       #{@flag_basics}
  #       creator { #{@user_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"flag" => flag} = gql_post_data(json_conn(), query)
  #   assert %{"creator" => user} = flag
  #   assert_flag(flag)
  #   assert_user(user)
  # end

  # test "flag.context" do
  #   for _ <- 1..30 do
  #     q = """
  #     query Test {
  #       flag(flagId: "") {
  #         #{@flag_basics}
  #         context {
  #           __typename
  #           ... on Collection { #{@collection_basics} }
  #           ... on Comment    { #{@comment_basics} }
  #           ... on Community  { #{@community_basics} }
  #           ... on Resource   { #{@resource_basics} }
  #           ... on User       { #{@user_basics} }
  #         }
  #       }
  #     }
  #     """
  #     query = %{query: q, operationName: "Test"}
  #     assert %{"flag" => flag} = gql_post_data(json_conn(), query)
  #     assert %{"context" => context} = flag
  #     assert_flag(flag)
  #     assert_flag_context(context)
  #   end
  # end

  # test "like" do
  #   q = """
  #   query Test {
  #     like(likeId: "") { #{@like_basics} }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"like" => like} = gql_post_data(json_conn(), query)
  #   assert_like(like)
  # end

  # test "like.creator" do
  #   q = """
  #   query Test {
  #     like(likeId: "") {
  #       #{@like_basics}
  #       creator { #{@user_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"like" => like} = gql_post_data(json_conn(), query)
  #   assert %{"creator" => user} = like
  #   assert_like(like)
  #   assert_user(user)
  # end

  # test "like.context" do
  #   q = """
  #   query Test {
  #     like(likeId: "") {
  #       #{@like_basics}
  #       context {
  #         __typename
  #         ... on Collection { #{@collection_basics} }
  #         ... on Comment    { #{@comment_basics} }
  #         ... on Resource   { #{@resource_basics} }
  #         ... on User       { #{@user_basics} }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"like" => like} = gql_post_data(json_conn(), query)
  #   assert %{"context" => context} = like
  #   assert_like(like)
  #   assert_like_context(context)
  # end
  
  # # @tag :skip
  # # test "tagging" do
  # #   q = """
  # #   query Test {
  # #     tagging(taggingId: "") {
  # #       #{@tagging_basics}
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"tagging" => tagging} = gql_post_data(json_conn(), query)
  # #   assert_tagging(tagging)
  # # end

  # # @tag :skip
  # # test "category.tags" do
  # #   q = """
  # #   query Test {
  # #     tagCategory(tagCategoryId: "") {
  # #       #{@tag_category_basics}
  # #       tags { ... }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"tagCategory" => cat} = gql_post_data(json_conn(), query)
  # #   assert %{"tags" => tags} = cat
  # #   assert_tag_category(cat)
  # # end

  # # test "tag.category" do
  # #   q = """
  # #   query Test {
  # #     tag(tagId: "") {
  # #       #{@tag_basics}
  # #       category { #{@tag_category_basics} }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"tag" => tag} = gql_post_data(json_conn(), query)
  # #   assert %{"category" => cat} = tag
  # #   assert_tag(tag)
  # #   assert_tag_category(cat)
  # # end
  # # @tag :skip
  # # test "tag.tagged" do
  # #   q = """
  # #   query Test {
  # #     tag(tagId: "") {
  # #       #{@tag_basics}
  # #       tagged { ... }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"tag" => tag} = gql_post_data(json_conn(), query)
  # #   assert %{"tagged" => tagged} = tag
  # #   assert_tag(tag)
  # # end

  # # test "tagging.tagger" do
  # #   q = """
  # #   query Test {
  # #     tagging(taggingId: "") {
  # #       #{@tagging_basics}
  # #       tagger { #{@user_basics} }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"tagging" => tagging} = gql_post_data(json_conn(), query)
  # #   assert %{"tagger" => user} = tagging
  # #   assert_tagging(tagging)
  # #   assert_user(user)
  # # end

  # # test "tagging.tag" do
  # #   q = """
  # #   query Test {
  # #     tagging(taggingId: "") {
  # #       #{@tagging_basics}
  # #       tag { #{@tag_basics} }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"tagging" => tagging} = gql_post_data(json_conn(), query)
  # #   assert %{"tag" => tag} = tagging
  # #   assert_tagging(tagging)
  # #   assert_tag(tag)
  # # end

  # # @tag :skip
  # # test "tagging.tagged" do
  # #   q = """
  # #   query Test {
  # #     tagging(taggingId: "") {
  # #       #{@tagging_basics}
  # #       tagged { ... } }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"tagging" => tagging} = gql_post_data(json_conn(), query)
  # #   assert %{"tagged" => tagged} = tagging
  # #   assert_tagging(tagging)
  # # end

  # # communities schema
  # test "communities" do
  #   q = """
  #   query Test {
  #     communities {
  #       #{@page_basics}
  #       nodes {
  #         #{@community_basics}
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"communities" => comm} = gql_post_data(json_conn(), query)
  #   for c <- assert_node_list(comm), do: assert_community(c)
  # end

  # test "community" do
  #   q = """
  #   query Test {
  #     community(communityId: "") {
  #       #{@community_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"community" => comm} = gql_post_data(json_conn(), query)
  #   assert_community(comm)
  # end

  # test "create_community" do
  #   vars = %{"community" => Fake.community_input()}
  #   q = """
  #   mutation Test($community: CommunityInput!) {
  #     createCommunity(community: $community) {
  #       #{@community_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test", variables: vars}
  #   assert %{"createCommunity" => comm} = gql_post_data(json_conn(), query)
  #   assert_community(comm)
  # end

  # test "update_community" do
  #   vars = %{"community" => Fake.community_input()}
  #   q = """
  #   mutation Test($community: CommunityInput!) {
  #     updateCommunity(communityId: "", community: $community) {
  #       #{@community_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test", variables: vars}
  #   assert %{"updateCommunity" => comm} = gql_post_data(json_conn(), query)
  #   assert_community(comm)
  # end

  # test "community.last_activity" do
  #   q = """
  #   query Test {
  #     community(communityId: "") {
  #       #{@community_basics}
  #       lastActivity
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"community" => comm} = gql_post_data(json_conn(), query)
  #   assert %{"lastActivity" => act} = comm
  #   assert is_binary(act)
  # end

  # test "community.my_follow" do
  #   q = """
  #   query Test {
  #     community(communityId: "") {
  #       myFollow { #{@follow_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"community" => comm} = gql_post_data(json_conn(), query)
  #   assert %{"myFollow" => follow} = comm
  #   assert_follow(follow)
  # end

  # # test "community.primary_language" do
  # #   q = """
  # #   query Test {
  # #     community(communityId: "") {
  # #       #{@community_basics}
  # #       primaryLanguage { #{@language_basics} }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operation_name: "Test"}
  # #   assert %{"community" => comm} = gql_post_data(json_conn(), query)
  # #   assert %{"primaryLanguage" => lang} = comm
  # #   assert_community(comm)
  # #   assert_language(lang)
  # # end

  # test "community.creator" do
  #   q = """
  #   query Test {
  #     community(communityId: "") {
  #       #{@community_basics}
  #       creator { #{@user_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"community" => comm} = gql_post_data(json_conn(), query)
  #   assert %{"creator" => user} = comm
  #   assert_community(comm)
  #   assert_user(user)
  # end

  # test "community.collections" do
  #   q = """
  #   query Test {
  #     community(communityId: "") {
  #       #{@community_basics}
  #       collections {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@collection_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"community" => comm} = gql_post_data(json_conn(), query)
  #   assert %{"collections" => colls} = comm
  #   assert_community(comm)
  #   for coll <- assert_edge_list(colls), do: assert_collection(coll)
  # end

  # test "community.threads" do
  #   q = """
  #   query Test {
  #     community(communityId: "") {
  #       #{@community_basics}
  #       threads {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@thread_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"community" => comm} = gql_post_data(json_conn(), query)
  #   assert %{"threads" => threads} = comm
  #   assert_community(comm)
  #   for thread <- assert_edge_list(threads), do: assert_thread(thread)
  # end

  # test "community.followers" do
  #   q = """
  #   query Test {
  #     community(communityId: "") {
  #       #{@community_basics}
  #       followers {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@follow_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"community" => comm} = gql_post_data(json_conn(), query)
  #   assert %{"followers" => follows} = comm
  #   assert_community(comm)
  #   for follow <- assert_edge_list(follows), do: assert_follow(follow)
  # end

  # test "community.inbox" do
  #   q = """
  #   query Test {
  #     community(communityId: "") {
  #       #{@community_basics}
  #       inbox {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@activity_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"community" => comm} = gql_post_data(json_conn(), query)
  #   assert %{"inbox" => inbox} = comm
  #   assert_community(comm)
  #   for activity <- assert_edge_list(inbox), do: assert_activity(activity)
  # end

  # test "community.outbox" do
  #   q = """
  #   query Test {
  #     community(communityId: "") {
  #       #{@community_basics}
  #       outbox {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@activity_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"community" => comm} = gql_post_data(json_conn(), query)
  #   assert %{"outbox" => outbox} = comm
  #   assert_community(comm)
  #   for activity <- assert_edge_list(outbox), do: assert_activity(activity)
  # end

  # # instance schema

  # # test "instance" do
  # #   q = """
  # #   query Test {
  # #     instance { }
  # #   }
  # #   """
  # # end

  # test "instance.outbox" do
  #   q = """
  #   query Test {
  #     instance {
  #       outbox {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@activity_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"instance" => inst} = gql_post_data(json_conn(), query)
  #   assert %{"outbox" => outbox} = inst
  #   for activity <- assert_edge_list(outbox), do: assert_activity(activity)
  # end

  # # localisation schema
  
  # # test "language" do
  # #   q = """
  # #   query Test {
  # #     language(languageId: "") {
  # #       #{@language_basics}
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"language" => lang} = gql_post_data(json_conn(), query)
  # #   assert_language(lang)
  # # end

  # # test "languages" do
  # #   q = """
  # #   query Test {
  # #     languages {
  # #       #{@page_basics}
  # #       nodes {
  # #         #{@language_basics}
  # #       }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"languages" => langs} = gql_post_data(json_conn(), query)
  # #   for lang <- assert_node_list(langs), do: assert_language(lang)
  # # end

  # # test "search_language" do
  # #   q = """
  # #   query Test {
  # #     searchLanguage(query: "") {
  # #       #{@page_basics}
  # #       nodes {
  # #         #{@language_basics}
  # #       }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"searchLanguage" => langs} = gql_post_data(json_conn(), query)
  # #   for lang <- assert_node_list(langs), do: assert_language(lang)
  # # end

  # # test "country" do
  # #   q = """
  # #   query Test {
  # #     country(countryId: "") {
  # #       #{@country_basics}
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"country" => country} = gql_post_data(json_conn(), query)
  # #   assert_country(country)
  # # end

  # # test "countries" do
  # #   q = """
  # #   query Test {
  # #     countries {
  # #       #{@page_basics}
  # #       nodes {
  # #         #{@country_basics}
  # #       }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"countries" => countries} = gql_post_data(json_conn(), query)
  # #   for country <- assert_node_list(countries), do: assert_country(country)
  # # end

  # # test "search_country" do
  # #   q = """
  # #   query Test {
  # #     searchCountry(query: "") {
  # #       #{@page_basics}
  # #       nodes {
  # #         #{@country_basics}
  # #       }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"searchCountry" => countries} = gql_post_data(json_conn(), query)
  # #   for country <- assert_node_list(countries), do: assert_country(country)
  # # end

  # # moodleverse schema

  # # test "moodleverse" do
  # #   q = """
  # #   query Test {
  # #     moodleverse { }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"moodleVerse" => %{}} = gql_post_data(json_conn(), query)
  # # end

  # # resources schema

  # test "resource" do
  #   q = """
  #   query Test {
  #     resource(resourceId: "") { #{@resource_basics} }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"resource" => res} = gql_post_data(json_conn(), query)
  #   assert_resource(res)
  # end

  # test "create_resource" do
  #   vars = %{"resource" => Fake.resource_input()}
  #   q = """
  #   mutation Test($resource: ResourceInput!) {
  #     createResource(resource: $resource, collectionId: "") {
  #       #{@resource_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test", variables: vars}
  #   assert %{"createResource" => res} = gql_post_data(json_conn(), query)
  #   assert_resource(res)
  # end

  # test "update_resource" do
  #   vars = %{"resource" => Fake.resource_input()}
  #   q = """
  #   mutation Test($resource: ResourceInput!) {
  #     updateResource(resourceId: "", resource: $resource) {
  #       #{@resource_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test", variables: vars}
  #   assert %{"updateResource" => res} = gql_post_data(json_conn(), query)
  #   assert_resource(res)
  # end

  # test "copy_resource" do
  #   q = """
  #   mutation Test {
  #     copyResource(resourceId: "", collectionId: "") {
  #       #{@resource_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"copyResource" => res} = gql_post_data(json_conn(), query)
  #   assert_resource(res)
  # end

  # test "resource.last_activity" do
  #   q = """
  #   query Test {
  #     resource(resourceId: "") {
  #       #{@resource_basics}
  #       lastActivity
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"resource" => res} = gql_post_data(json_conn(), query)
  #   assert_resource(res)
  #   assert %{"lastActivity" => act} = res
  #   assert is_binary(act)
  # end

  # test "resource.my_like" do
  #   q = """
  #   query Test {
  #     resource(resourceId: "") {
  #       #{@resource_basics}
  #       myLike { #{@like_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"resource" => res} = gql_post_data(json_conn(), query)
  #   assert %{"myLike" => like} = res
  #   assert_resource(res)
  #   assert_like(like)
  # end

  # test "resource.creator" do
  #   q = """
  #   query Test {
  #     resource(resourceId: "") {
  #       #{@resource_basics}
  #      creator { #{@user_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"resource" => res} = gql_post_data(json_conn(), query)
  #   assert %{"creator" => user} = res
  #   assert_resource(res)
  #   assert_user(user)
  # end

  # test "resource.collection" do
  #   q = """
  #   query Test {
  #     resource(resourceId: "") {
  #       #{@resource_basics}
  #       collection { #{@collection_basics} }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"resource" => res} = gql_post_data(json_conn(), query)
  #   assert %{"collection" => coll} = res
  #   assert_resource(res)
  #   assert_collection(coll)
  # end

  # # test "resource.primary_language" do
  # #   q = """
  # #   query Test {
  # #     resource(resourceId: "") {
  # #       #{@resource_basics}
  # #       primaryLanguage { #{@language_basics} }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"resource" => res} = gql_post_data(json_conn(), query)
  # #   assert %{"primaryLanguage" => lang} = res
  # #   assert_resource(res)
  # #   assert_language(lang)
  # # end

  # test "resource.likes" do
  #   q = """
  #   query Test {
  #     resource(resourceId: "") {
  #       #{@resource_basics}
  #       likes {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@like_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"resource" => res} = gql_post_data(json_conn(), query)
  #   assert %{"likes" => likes} = res
  #   assert_resource(res)
  #   for like <- assert_edge_list(likes), do: assert_like(like)
  # end

  # test "resource.flags" do
  #   q = """
  #   query Test {
  #     resource(resourceId: "") {
  #       #{@resource_basics}
  #       flags {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@flag_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"resource" => res} = gql_post_data(json_conn(), query)
  #   assert_resource(res)
  #   assert %{"flags" => flags} = res
  #   for flag <- assert_edge_list(flags), do: assert_flag(flag)
  # end

  # # @tag :skip
  # # test "resource.tags" do
  # #   q = """
  # #   query Test {
  # #     resource(resourceId: "") {
  # #       #{@resource_basics}
  # #       tags {
  # #         #{@page_basics}
  # #         edges {
  # #           cursor
  # #           node { #{@tag_basics} }
  # #         }
  # #       }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"resource" => res} = gql_post_data(json_conn(), query)
  # #   assert_resource(res)
  # #   assert %{"tags" => tags} = res
  # #   for tagging <- assert_edge_list(tags), do: assert_tagging(tagging)
  # # end

  # # users schema

  # test "username_available" do
  #   q = """
  #   query Test {
  #     usernameAvailable(username: "")
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"usernameAvailable" => av} = gql_post_data(json_conn(), query)
  #   assert is_boolean(av)
  # end

  # # test "me" do
  # #   q = """
  # #   query Test {
  # #     me {
  # #       #{@me_basics}
  # #       user { #{@user_basics} }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"me" => me} = gql_post_data(json_conn(), query)
  # #   assert_me(me)
  # # end

  # test "user" do
  #   q = """
  #   query Test {
  #     user(userId: "") {
  #       #{@user_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  #   assert_user(user)
  # end
  
  # test "create_user" do
  #   vars = %{"user" => Fake.registration_input()}
  #   q = """
  #   mutation Test($user: RegistrationInput!) {
  #     createUser(user: $user) {
  #       user { #{@user_basics} }
  #       #{@me_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, variables: vars, operationName: "Test"}
  #   assert %{"createUser" => me} = gql_post_data(json_conn(), query)
  #   assert_me(me)
  # end

  # test "update_profile" do
  #   vars = %{"profile" => Fake.profile_update_input()}
  #   q = """
  #   mutation Test($profile: UpdateProfileInput!) {
  #     updateProfile(profile: $profile) {
  #       user { #{@user_basics} }
  #       #{@me_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, variables: vars, operationName: "Test"}
  #   assert %{"updateProfile" => me} = gql_post_data(json_conn(), query)
  #   assert_me(me)
  # end

  # test "reset_request" do
  #   vars = %{"email" => ""}
  #   q = """
  #   mutation Test($email: String!) {
  #     resetPasswordRequest(email: $email)
  #   }
  #   """
  #   query = %{query: q, variables: vars, operationName: "Test"}
  #   assert %{"resetPasswordRequest" => true} = gql_post_data(json_conn(), query)
  # end

  # test "reset" do
  #   vars = %{"token" => "", "password" => ""}
  #   q = """
  #   mutation Test($token: String!, $password: String!) {
  #     resetPassword(token: $token, password: $password) {
  #       __typename
  #       token
  #       me {
  #         user { #{@user_basics} }
  #         #{@me_basics}
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, variables: vars, operationName: "Test"}
  #   assert %{"resetPassword" => auth} = gql_post_data(json_conn(), query)
  #   assert_auth_payload(auth)
  # end

  # test "confirm" do
  #   vars = %{"token" => ""}
  #   q = """
  #   mutation Test($token: String!) {
  #     confirmEmail(token: $token) {
  #       __typename
  #       token
  #       me {
  #         user { #{@user_basics} }
  #         #{@me_basics}
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, variables: vars, operationName: "Test"}
  #   assert %{"confirmEmail" => auth} = gql_post_data(json_conn(), query)
  #   assert_auth_payload(auth)
  # end

  # test "login" do
  #   vars = %{"email" => "", "password" => ""}
  #   q = """
  #   mutation Test($email: String!, $password: String!) {
  #     createSession(email: $email, password: $password) {
  #       __typename
  #       token
  #       me {
  #         user { #{@user_basics} }
  #         #{@me_basics}
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, variables: vars, operationName: "Test"}
  #   assert %{"createSession" => auth} = gql_post_data(json_conn(), query)
  #   assert_auth_payload(auth)
  # end

  # test "logout" do
  #   vars = %{}
  #   q = """
  #   mutation Test {
  #     deleteSession
  #   }
  #   """
  #   query = %{query: q, variables: vars, operationName: "Test"}
  #   assert %{"deleteSession" => true} = gql_post_data(json_conn(), query)
  # end

  # test "delete" do
  #   vars = %{"iAmSure" => true}
  #   q = """
  #   mutation Test {
  #     deleteSelf(iAmSure: true)
  #   }
  #   """
  #   query = %{query: q, variables: vars, operationName: "Test"}
  #   assert %{"deleteSelf" => true} = gql_post_data(json_conn(), query)
  #  end
 
  # test "user.last_activity" do
  #   q = """
  #   query Test {
  #     user(userId: "") { #{@user_basics} lastActivity }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  #   assert %{"lastActivity" => activity} = user
  #   assert_user(user)
  #   assert is_binary(activity)
  # end

  # test "user.my_follow" do
  #   q = """
  #   query Test {
  #     user(userId: "") {
  #       myFollow { #{@follow_basics} }
  #       #{@user_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  #   assert %{"myFollow" => follow} = user
  #   assert_user(user)
  #   assert_follow(follow)
  # end

  # test "user.my_like" do
  #   q = """
  #   query Test {
  #     user(userId: "") {
  #       myLike { #{@like_basics} }
  #       #{@user_basics}
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  #   assert %{"myLike" => like} = user
  #   assert_user(user)
  #   assert_like(like)
  #  end
  
  # # test "user.primary_language" do
  # #   q = """
  # #   query Test {
  # #     user(userId: "") {
  # #       #{@user_basics}
  # #       primaryLanguage { #{@language_basics} }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  # #   assert_user(user)
  # #   assert %{"primaryLanguage" => lang} = user
  # #   assert_language(lang)
  # # end

  # test "user.followed_communities" do
  #   q = """
  #   query Test {
  #     user(userId: "") {
  #       #{@user_basics}
  #       followedCommunities {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node {
  #             follow { #{@follow_basics} }
  # 	      community { #{@community_basics} }
  #           }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  #   assert_user(user)
  #   assert %{"followedCommunities" => follows} = user
  #   for f <- assert_edge_list(follows) do
  #     assert_follow(f["follow"])
  #     assert_community(f["community"])
  #   end
  # end

  # test "user.followed_collections" do
  #   q = """
  #   query Test {
  #     user(userId: "") {
  #       #{@user_basics}
  #       followedCollections {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node {
  #             follow { #{@follow_basics} }
  #             collection { #{@collection_basics} }
  #           }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  #   assert_user(user)
  #   assert %{"followedCollections" => follows} = user
  #   for f <- assert_edge_list(follows) do
  #     assert_follow(f["follow"])
  #     assert_collection(f["collection"])
  #   end
  # end

  # test "user.followed_users" do
  #   q = """
  #   query Test {
  #     user(userId: "") {
  #       #{@user_basics}
  #       followedUsers {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node {
  #             follow { #{@follow_basics} }
  #             user { #{@user_basics} }
  #           }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  #   assert_user(user)
  #   assert %{"followedUsers" => follows} = user
  #   for f <- assert_edge_list(follows) do
  #     assert_follow(f["follow"])
  #     assert_user(f["user"])
  #   end
  # end

  # test "user.likes" do
  #   q = """
  #   query Test {
  #     user(userId: "") {
  #       #{@user_basics}
  #       likes {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@like_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  #   assert_user(user)
  #   assert %{"likes" => likes} = user
  #   for like <- assert_edge_list(likes), do: assert_like(like)
  # end

  # test "user.comments" do
  #   q = """
  #   query Test {
  #     user(userId: "") {
  #       #{@user_basics}
  #       comments {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@comment_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  #   assert_user(user)
  #   assert %{"comments" => comments} = user
  #   for c <- assert_edge_list(comments), do: assert_comment(c)
  # end

  # test "user.outbox" do
  #   q = """
  #   query Test {
  #     user(userId: "") {
  #       #{@user_basics}
  #       outbox {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@activity_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  #   assert_user(user)
  #   assert %{"outbox" => outbox} = user
  #   for node <- assert_edge_list(outbox), do: assert_activity(node)
  # end

  # test "user.inbox" do
  #   q = """
  #   query Test {
  #     user(userId: "") {
  #       #{@user_basics}
  #       inbox {
  #         #{@page_basics}
  #         edges {
  #           cursor
  #           node { #{@activity_basics} }
  #         }
  #       }
  #     }
  #   }
  #   """
  #   query = %{query: q, operationName: "Test"}
  #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  #   assert_user(user)
  #   assert %{"inbox" => inbox} = user
  #   for node <- assert_edge_list(inbox), do: assert_activity(node)
  # end

  # # @tag :skip
  # # test "user.tagged" do
  # #   q = """
  # #   query Test {
  # #     user(userId: "") {
  # #       #{@user_basics}
  # #       tagged {
  # #         #{@page_basics}
  # #         edges {
  # #           cursor
  # #           node { #{@tagging_basics} }
  # #         }
  # #       }
  # #     }
  # #   }
  # #   """
  # #   query = %{query: q, operationName: "Test"}
  # #   assert %{"user" => user} = gql_post_data(json_conn(), query)
  # #   assert_user(user)
  # # end

end
