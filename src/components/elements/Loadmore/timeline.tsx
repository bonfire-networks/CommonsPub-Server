import * as React from 'react';
import { SFC } from 'react';
import styled from '../../../themes/styled';
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
          variables: {
            end: community.inbox.pageInfo.endCursor
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const newNodes = fetchMoreResult.community.inbox.edges;
            const pageInfo = fetchMoreResult.community.inbox.pageInfo;
            return newNodes.length
              ? {
                  // Put the new comments at the end of the list and update `pageInfo`
                  // so we have the new `endCursor` and `hasNextPage` values
                  community: {
                    ...previousResult.community,
                    __typename: previousResult.community.__typename,
                    inbox: {
                      ...previousResult.community.inbox,
                      edges: [
                        ...previousResult.community.inbox.edges,
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
                    inbox: {
                      ...previousResult.community.inbox,
                      edges: [...previousResult.community.inbox.edges]
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

export const LoadMore = styled.div`
  text-align: center;
  vertical-align: middle;
  cursor: pointer;
  white-space: nowrap;
  line-height: 20px;
  padding: 8px 13px;
  border-radius: 4px;
  user-select: none;
  color: #667d99;
  background: #e7edf3;
  background-color: rgb(231, 237, 243);
  background-color: rgb(231, 237, 243);
  border: 0;
  font-size: 13px;
  margin-top: 8px;
  font-weight: 500;
  &:hover {
    background: #e7e7e7;
  }
`;
