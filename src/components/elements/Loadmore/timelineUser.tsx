import * as React from 'react';
import { SFC } from 'react';
import { LoadMore } from './timeline';
import { Trans } from '@lingui/macro';

interface Props {
  community: any;
  fetchMore: any;
}

const TimelineLoadMore: SFC<Props> = ({ fetchMore, community }) =>
  (community.inbox.pageInfo.startCursor === null &&
    community.inbox.pageInfo.endCursor === null) ||
  (community.inbox.pageInfo.startCursor &&
    community.inbox.pageInfo.endCursor === null) ? null : (
    <LoadMore
      onClick={() =>
        fetchMore({
          fetchPolicy: 'cache-first',
          variables: {
            end: community.inbox.pageInfo.endCursor
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const newNodes = fetchMoreResult.me.user.inbox.edges;
            const pageInfo = fetchMoreResult.me.user.inbox.pageInfo;
            return newNodes.length
              ? {
                  // Put the new comments at the end of the list and update `pageInfo`
                  // so we have the new `endCursor` and `hasNextPage` values
                  me: {
                    ...previousResult.me,
                    __typename: previousResult.me.__typename,
                    user: {
                      id: previousResult.me.user.id,
                      __typename: previousResult.me.user.__typename,
                      inbox: {
                        ...previousResult.me.user.inbox,
                        edges: [
                          ...previousResult.me.user.inbox.edges,
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
                    __typename: previousResult.me.__typename,
                    user: {
                      id: previousResult.me.user.id,
                      __typename: previousResult.me.user.__typename,
                      inbox: {
                        ...previousResult.me.user.inbox,
                        edges: [...previousResult.me.user.inbox.edges],
                        pageInfo
                      }
                    }
                  }
                };
          }
        })
      }
    >
      <Trans>Load more</Trans>
    </LoadMore>
  );

export default TimelineLoadMore;
