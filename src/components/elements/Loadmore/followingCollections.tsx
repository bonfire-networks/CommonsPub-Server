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
                    me: {
                      ...previousResult.me,
                      user: {
                        ...previousResult.me.user,
                        followingCollections: {
                          ...previousResult.me.user.followingCollections,
                          edges: [
                            ...previousResult.me.user.followingCollections
                              .edges,
                            ...newNodes
                          ],
                          pageInfo
                        }
                      }
                    }
                  }
                : {
                    me: {
                      ...previousResult.me,
                      user: {
                        ...previousResult.me.user,
                        followingCollections: {
                          ...previousResult.me.user.followingCollections,
                          edges: [
                            ...previousResult.me.user.followingCollections.edges
                          ],
                          pageInfo
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
                    user: {
                      ...previousResult.user,
                      followingCollections: {
                        ...previousResult.user.followingCollections,
                        edges: [
                          ...previousResult.user.followingCollections.edges,
                          ...newNodes
                        ],
                        pageInfo
                      }
                    }
                  }
                : {
                    user: {
                      ...previousResult.user,
                      followingCollections: {
                        ...previousResult.user.followingCollections,
                        edges: [
                          ...previousResult.user.followingCollections.edges
                        ],
                        pageInfo
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
