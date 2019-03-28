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
                      __typename: previousResult.me.__typename,
                      user: {
                        id: previousResult.me.user.id,
                        __typename: previousResult.me.user.__typename,
                        joinedCommunities: {
                          edges: [
                            ...previousResult.me.user.joinedCommunities.edges,
                            ...newNodes
                          ],
                          pageInfo,
                          __typename:
                            previousResult.me.user.joinedCommunities.__typename
                        }
                      }
                    }
                  }
                : {
                    me: {
                      __typename: previousResult.me.__typename,
                      user: {
                        id: previousResult.me.user.id,
                        __typename: previousResult.me.user.__typename,
                        joinedCommunities: {
                          edges: [
                            ...previousResult.me.user.joinedCommunities.edges
                          ],
                          pageInfo,
                          __typename:
                            previousResult.me.user.joinedCommunities.__typename
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
                      id: previousResult.user.id,
                      __typename: previousResult.user.__typename,
                      joinedCommunities: {
                        edges: [
                          ...previousResult.user.joinedCommunities.edges,
                          ...newNodes
                        ],
                        pageInfo,
                        __typename:
                          previousResult.user.joinedCommunities.__typename
                      }
                    }
                  }
                : {
                    user: {
                      id: previousResult.user.id,
                      __typename: previousResult.user.__typename,
                      joinedCommunities: {
                        edges: [...previousResult.user.joinedCommunities.edges],
                        pageInfo,
                        __typename:
                          previousResult.user.joinedCommunities.__typename
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
