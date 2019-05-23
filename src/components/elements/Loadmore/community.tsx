import * as React from 'react';
import { SFC } from 'react';
import { LoadMore } from './timeline';
import { Trans } from '@lingui/macro';

interface Props {
  communities: any;
  fetchMore: any;
}

const CommunitiesLoadMore: SFC<Props> = ({ fetchMore, communities }) =>
  (communities.pageInfo.startCursor === null &&
    communities.pageInfo.endCursor === null) ||
  (communities.pageInfo.startCursor &&
    communities.pageInfo.endCursor === null) ? null : (
    <LoadMore
      onClick={() =>
        fetchMore({
          fetchPolicy: 'cache-first',
          variables: {
            end: communities.pageInfo.endCursor
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const newNodes = fetchMoreResult.communities.nodes;
            const pageInfo = fetchMoreResult.communities.pageInfo;
            return newNodes.length
              ? {
                  // Put the new comments at the end of the list and update `pageInfo`
                  // so we have the new `endCursor` and `hasNextPage` values
                  communities: {
                    __typename: previousResult.communities.__typename,
                    nodes: [...previousResult.communities.nodes, ...newNodes],
                    pageInfo
                  }
                }
              : {
                  communities: {
                    __typename: previousResult.communities.__typename,
                    nodes: [...previousResult.communities.nodes],
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

export default CommunitiesLoadMore;
