import * as React from 'react';
import { SFC } from 'react';
import { Trans } from '@lingui/macro';
import { LoadMore } from './timeline';

interface Props {
  community: any;
  fetchMore: any;
  me?: boolean;
}

const TimelineLoadMore: SFC<Props> = ({ fetchMore, me, community }) =>
  (community.outbox.pageInfo.startCursor === null &&
    community.outbox.pageInfo.endCursor === null) ||
  (community.outbox.pageInfo.startCursor &&
    community.outbox.pageInfo.endCursor === null) ? null : (
    <LoadMore
      onClick={() =>
        fetchMore({
          variables: {
            endTimeline: community.outbox.pageInfo.endCursor
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            if (me) {
              const newNodes = fetchMoreResult.me.user.outbox.edges;
              const pageInfo = fetchMoreResult.me.user.outbox.pageInfo;
              return newNodes.length
                ? {
                    // Put the new comments at the end of the list and update `pageInfo`
                    // so we have the new `endCursor` and `hasNextPage` values
                    me: {
                      ...previousResult.me,
                      user: {
                        ...previousResult.me.user,
                        outbox: {
                          ...previousResult.me.user.outbox,
                          edges: [
                            ...previousResult.me.user.outbox.edges,
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
                        outbox: {
                          ...previousResult.me.user.outbox,
                          edges: [...previousResult.me.user.outbox.edges],
                          pageInfo
                        }
                      }
                    }
                  };
            } else {
              const newNodes = fetchMoreResult.user.outbox.edges;
              const pageInfo = fetchMoreResult.user.outbox.pageInfo;
              return newNodes.length
                ? {
                    user: {
                      ...previousResult.user,
                      outbox: {
                        ...previousResult.user.outbox,
                        edges: [
                          ...previousResult.user.outbox.edges,
                          ...newNodes
                        ],
                        pageInfo
                      }
                    }
                  }
                : {
                    user: {
                      ...previousResult.user,
                      outbox: {
                        ...previousResult.user.outbox,
                        edges: [...previousResult.user.outbox.edges],
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

export default TimelineLoadMore;
