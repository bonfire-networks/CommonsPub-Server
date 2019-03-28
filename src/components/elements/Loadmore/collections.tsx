import * as React from 'react';
import { SFC } from 'react';
import { LoadMore } from './timeline';
import { Trans } from '@lingui/macro';

interface Props {
  collections: any;
  fetchMore: any;
}

const CollectionsLoadMore: SFC<Props> = ({ fetchMore, collections }) =>
  (collections.pageInfo.startCursor === null &&
    collections.pageInfo.endCursor === null) ||
  (collections.pageInfo.startCursor &&
    collections.pageInfo.endCursor === null) ? null : (
    <LoadMore
      onClick={() =>
        fetchMore({
          variables: {
            end: collections.pageInfo.endCursor
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const newNodes = fetchMoreResult.collections.nodes;
            const pageInfo = fetchMoreResult.collections.pageInfo;
            return newNodes.length
              ? {
                  collections: {
                    __typename: previousResult.collections.__typename,
                    nodes: [...previousResult.collections.nodes, ...newNodes],
                    pageInfo
                  }
                }
              : {
                  collections: {
                    __typename: previousResult.collections.__typename,
                    nodes: [...previousResult.collections.nodes],
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

export default CollectionsLoadMore;
