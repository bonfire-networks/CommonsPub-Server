import * as React from 'react';
import { SFC } from 'react';
import { LoadMore } from './timeline';
import { Trans } from '@lingui/macro';

interface Props {
  collections: any;
  fetchMore: any;
  me?: boolean;
}

const CollectionsLoadMore: SFC<Props> = ({ fetchMore, collections, me }) =>
  (collections.pageInfo.startCursor === null &&
    collections.pageInfo.endCursor === null) ||
  (collections.pageInfo.startCursor &&
    collections.pageInfo.endCursor === null) ? null : (
    <LoadMore
      onClick={() =>
        fetchMore({
          variables: {
            endColl: collections.pageInfo.endCursor
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            if (me) {
              const newNodes =
                fetchMoreResult.me.user.followingCollections.edges;
              const pageInfo =
                fetchMoreResult.me.user.followingCollections.pageInfo;
              return newNodes.length
                ? {
                    // Put the new comments at the end of the list and update `pageInfo`
                    // so we have the new `endCursor` and `hasNextPage` values
                    me: {
                      __typename: previousResult.me.__typename,
                      user: {
                        name: previousResult.me.user.name,
                        location: previousResult.me.user.location,
                        summary: previousResult.me.user.summary,
                        icon: previousResult.me.user.icon,
                        joinedCommunities:
                          previousResult.me.user.joinedCommunities,
                        preferredUsername:
                          previousResult.me.user.preferredUsername,
                        id: previousResult.me.user.id,
                        __typename: previousResult.me.user.__typename,
                        followingCollections: {
                          edges: [
                            ...previousResult.me.user.followingCollections
                              .edges,
                            ...newNodes
                          ],
                          pageInfo,
                          __typename:
                            previousResult.me.user.followingCollections
                              .__typename
                        }
                      }
                    }
                  }
                : {
                    me: {
                      __typename: previousResult.me.__typename,
                      user: {
                        id: previousResult.me.user.id,
                        name: previousResult.me.user.name,
                        location: previousResult.me.user.location,
                        summary: previousResult.me.user.summary,
                        icon: previousResult.me.user.icon,
                        joinedCommunities:
                          previousResult.me.user.joinedCommunities,
                        preferredUsername:
                          previousResult.me.user.preferredUsername,
                        __typename: previousResult.me.user.__typename,
                        followingCollections: {
                          edges: [
                            ...previousResult.me.user.followingCollections.edges
                          ],
                          pageInfo,
                          __typename:
                            previousResult.me.user.followingCollections
                              .__typename
                        }
                      }
                    }
                  };
            } else {
              const newNodes = fetchMoreResult.user.followingCollections.edges;
              const pageInfo =
                fetchMoreResult.user.followingCollections.pageInfo;
              return newNodes.length
                ? {
                    // Put the new comments at the end of the list and update `pageInfo`
                    // so we have the new `endCursor` and `hasNextPage` values

                    user: {
                      name: previousResult.user.name,
                      location: previousResult.user.location,
                      summary: previousResult.user.summary,
                      icon: previousResult.user.icon,
                      joinedCommunities: previousResult.user.joinedCommunities,
                      preferredUsername: previousResult.user.preferredUsername,
                      id: previousResult.user.id,
                      localId: previousResult.user.localId,
                      __typename: previousResult.user.__typename,
                      followingCollections: {
                        edges: [
                          ...previousResult.user.followingCollections.edges,
                          ...newNodes
                        ],
                        pageInfo,
                        __typename:
                          previousResult.user.followingCollections.__typename
                      }
                    }
                  }
                : {
                    __typename: previousResult.__typename,
                    user: {
                      id: previousResult.user.id,
                      localId: previousResult.user.localId,

                      name: previousResult.user.name,
                      location: previousResult.user.location,
                      summary: previousResult.user.summary,
                      icon: previousResult.user.icon,
                      joinedCommunities: previousResult.user.joinedCommunities,
                      preferredUsername: previousResult.user.preferredUsername,
                      __typename: previousResult.user.__typename,
                      followingCollections: {
                        edges: [
                          ...previousResult.user.followingCollections.edges
                        ],
                        pageInfo,
                        __typename:
                          previousResult.user.followingCollections.__typename
                      }
                    }
                  };
            }
          }
        })
      }
    >
      <Trans>Load more</Trans>
    </LoadMore>
  );

export default CollectionsLoadMore;
