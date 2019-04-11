import * as React from 'react';
import { SFC } from 'react';
import { Trans } from '@lingui/macro';
import { LoadMore } from './timeline';

interface Props {
  community: any;
  fetchMore: any;
}

const TimelineLoadMore: SFC<Props> = ({ fetchMore, community }) =>
  (community.outbox.pageInfo.startCursor === null &&
    community.outbox.pageInfo.endCursor === null) ||
  (community.outbox.pageInfo.startCursor &&
    community.outbox.pageInfo.endCursor === null) ? null : (
    <LoadMore
      onClick={() =>
        fetchMore({
          variables: {
            end: community.outbox.pageInfo.endCursor
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const newNodes = fetchMoreResult.community.outbox.edges;
            const pageInfo = fetchMoreResult.community.outbox.pageInfo;
            return newNodes.length
              ? {
                  // Put the new comments at the end of the list and update `pageInfo`
                  // so we have the new `endCursor` and `hasNextPage` values
                  community: {
                    ...previousResult.community,
                    __typename: previousResult.community.__typename,
                    outbox: {
                      ...previousResult.community.outbox,
                      edges: [
                        ...previousResult.community.outbox.edges,
                        ...newNodes
                      ]
                    },
                    pageInfo
                  }
                }
              : {
                  community: {
                    ...previousResult.community,
                    __typename: previousResult.community.__typename,
                    outbox: {
                      ...previousResult.community.outbox,
                      edges: [...previousResult.community.outbox.edges]
                    },
                    pageInfo
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
