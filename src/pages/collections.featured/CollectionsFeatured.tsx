import * as React from 'react';
import compose from 'recompose/compose';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';

import { Trans } from '@lingui/macro';

import H4 from '../../components/typography/H4/H4';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
import Collection from '../../types/Collection';
import Loader from '../../components/elements/Loader/Loader';
import CollectionCard from '../../components/elements/Collection/Collection';

const { getCollectionsQuery } = require('../../graphql/getCollections.graphql');

interface Data extends GraphqlQueryControls {
  collections: {
    nodes: Collection[];
    pageInfo: {
      startCursor: number;
      endCursor: number;
    };
  };
}

interface Props {
  data: Data;
}

class CommunitiesYours extends React.Component<Props> {
  render() {
    return (
      <Main>
        <WrapperCont>
          <Wrapper>
            <H4>
              <Trans>All Collections</Trans>
            </H4>
            {this.props.data.error ? (
              <span>
                <Trans>Error loading collections</Trans>
              </span>
            ) : this.props.data.loading ? (
              <Loader />
            ) : (
              <>
                <List>
                  {this.props.data.collections.nodes.map((coll, i) => (
                    <CollectionCard
                      key={i}
                      collection={coll}
                      communityId={coll.community.localId}
                    />
                  ))}
                </List>
                {(this.props.data.collections.pageInfo.startCursor &&
                  this.props.data.collections.pageInfo.endCursor === null) ||
                (this.props.data.collections.pageInfo.startCursor === null &&
                  this.props.data.collections.pageInfo.endCursor ===
                    null) ? null : (
                  <LoadMore
                    onClick={() =>
                      this.props.data.fetchMore({
                        variables: {
                          end: this.props.data.collections.pageInfo.endCursor
                        },
                        updateQuery: (previousResult, { fetchMoreResult }) => {
                          const newNodes = fetchMoreResult.collections.nodes;
                          const pageInfo = fetchMoreResult.collections.pageInfo;
                          return newNodes.length
                            ? {
                                // Put the new comments at the end of the list and update `pageInfo`
                                // so we have the new `endCursor` and `hasNextPage` values
                                collections: {
                                  __typename:
                                    previousResult.collections.__typename,
                                  nodes: [
                                    ...previousResult.collections.nodes,
                                    ...newNodes
                                  ],
                                  pageInfo
                                }
                              }
                            : {
                                collections: {
                                  __typename:
                                    previousResult.collections.__typename,
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
                )}
              </>
            )}
          </Wrapper>
        </WrapperCont>
      </Main>
    );
  }
}

const LoadMore = styled.div`
  height: 50px;
  line-height: 50px;
  text-align: center;
  border-top: 1px solid #ececec;
  color: #74706b;
  letter-spacing: 0.5px;
  font-size: 14px;
  background: #f0f1f2;
  font-weight: 600;
  cursor: pointer;
  &:hover {
    background: #e7e7e7;
  }
`;

const WrapperCont = styled.div`
  max-width: 1040px;
  margin: 0 auto;
  width: 100%;
  height: 100%;
  background: white;
  margin-top: 24px;
  border-radius: 4px;
`;

const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  flex: 1;
  margin-bottom: 24px;

  & h4 {
    padding-left: 8px;
    margin: 0;
    border-bottom: 1px solid #dadada;
    margin-bottom: 20px !important;
    line-height: 32px !important;
    background-color: #151b26;
    border-bottom: 1px solid #dddfe2;
    border-radius: 2px 2px 0 0;
    font-weight: bold;
    font-size: 14px !important;
    color: #fff;
  }
`;
const List = styled.div`
  display: grid;
  grid-template-columns: 1fr;
  grid-column-gap: 16px;
  grid-row-gap: 16px;
  background: white;
`;

const withGetCommunities = graphql<
  {},
  {
    data: {
      communities: Collection[];
    };
  }
>(getCollectionsQuery, {
  options: (props: Props) => ({
    variables: {
      limit: 15
    }
  })
}) as OperationOption<{}, {}>;

export default compose(withGetCommunities)(CommunitiesYours);
