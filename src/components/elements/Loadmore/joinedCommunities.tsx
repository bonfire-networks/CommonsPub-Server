import * as React from 'react';
import { SFC } from 'react';
import { LoadMore } from './timeline';
import { Trans } from '@lingui/macro';

interface Props {
  communities: any;
  fetchMore: any;
  me?: boolean;
}

const JoinedCommunitiesLoadMore: SFC<Props> = ({
  fetchMore,
  me,
  communities
}) =>
  (communities.pageInfo.startCursor === null &&
    communities.pageInfo.endCursor === null) ||
  (communities.pageInfo.startCursor &&
    communities.pageInfo.endCursor === null) ? null : (
    <LoadMore
      onClick={() =>
        fetchMore({
          variables: {
            endComm: communities.pageInfo.endCursor
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            if (me) {
              const newNodes = fetchMoreResult.me.user.joinedCommunities.edges;
              const pageInfo =
                fetchMoreResult.me.user.joinedCommunities.pageInfo;
              return newNodes.length
                ? {
                    // Put the new comments at the end of the list and update `pageInfo`
                    // so we have the new `endCursor` and `hasNextPage` values
                    me: {
                      ...previousResult.me,
                      user: {
                        ...previousResult.me.user,
                        joinedCommunities: {
                          ...previousResult.me.user,
                          edges: [
                            ...previousResult.me.user.joinedCommunities.edges,
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
                        joinedCommunities: {
                          ...previousResult.me.user.joinedCommunities,
                          edges: [
                            ...previousResult.me.user.joinedCommunities.edges
                          ],
                          pageInfo
                        }
                      }
                    }
                  };
            } else {
              const newNodes = fetchMoreResult.user.joinedCommunities.edges;
              const pageInfo = fetchMoreResult.user.joinedCommunities.pageInfo;
              return newNodes.length
                ? {
                    // Put the new comments at the end of the list and update `pageInfo`
                    // so we have the new `endCursor` and `hasNextPage` values

                    user: {
                      ...previousResult.user,
                      joinedCommunities: {
                        ...previousResult.user.joinedCommunities,
                        edges: [
                          ...previousResult.user.joinedCommunities.edges,
                          ...newNodes
                        ],
                        pageInfo
                      }
                    }
                  }
                : {
                    user: {
                      ...previousResult.user,
                      joinedCommunities: {
                        ...previousResult.user.joinedCommunities,
                        edges: [...previousResult.user.joinedCommunities.edges],
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

export default JoinedCommunitiesLoadMore;
