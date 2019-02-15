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

const {
  getFollowedCollections
} = require('../../graphql/getFollowedCollections.graphql');

interface Data extends GraphqlQueryControls {
  me: {
    user: {
      followingCollections: {
        edges: any[];
        pageInfo: {
          startCursor: number;
          endCursor: number;
        };
      };
    };
  };
}

interface Props {
  data: Data;
}

class CommunitiesYours extends React.Component<Props> {
  render() {
    let body;

    if (this.props.data.error) {
      body = (
        <span>
          <Trans>Error loading collections</Trans>
        </span>
      );
    } else if (this.props.data.loading) {
      body = <Loader />;
    } else {
      body = this.props.data.me.user.followingCollections.edges.map(
        (comm, i) => (
          <CollectionCard
            key={i}
            collection={comm}
            communityId={comm.localId}
          />
        )
      );
    }
    console.log(body);
    return (
      <Main>
        <WrapperCont>
          <Wrapper>
            <H4>
              <Trans>Followed Collections</Trans>
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
                  {this.props.data.me.user.followingCollections.edges.map(
                    (comm, i) => (
                      <CollectionCard
                        key={i}
                        collection={comm}
                        communityId={comm.localId}
                      />
                    )
                  )}
                </List>
                {(this.props.data.me.user.followingCollections.pageInfo
                  .startCursor &&
                  this.props.data.me.user.followingCollections.pageInfo
                    .endCursor === null) ||
                (this.props.data.me.user.followingCollections.pageInfo
                  .startCursor === null &&
                  this.props.data.me.user.followingCollections.pageInfo
                    .endCursor === null) ? null : (
                  <LoadMore
                    onClick={() =>
                      this.props.data.fetchMore({
                        variables: {
                          end: this.props.data.me.user.followingCollections
                            .pageInfo.endCursor
                        },
                        updateQuery: (previousResult, { fetchMoreResult }) => {
                          const newNodes =
                            fetchMoreResult.me.user.followingCollections.edges;
                          const pageInfo =
                            fetchMoreResult.me.user.followingCollections
                              .pageInfo;
                          return newNodes.length
                            ? {
                                // Put the new comments at the end of the list and update `pageInfo`
                                // so we have the new `endCursor` and `hasNextPage` values
                                me: {
                                  __typename: previousResult.me.__typename,
                                  user: {
                                    id: previousResult.me.user.id,
                                    __typename:
                                      previousResult.me.user.__typename,
                                    followingCollections: {
                                      edges: [
                                        ...previousResult.me.user
                                          .followingCollections.edges,
                                        ...newNodes
                                      ],
                                      pageInfo,
                                      __typename:
                                        previousResult.me.user
                                          .followingCollections.__typename
                                    }
                                  }
                                }
                              }
                            : {
                                me: {
                                  __typename: previousResult.me.__typename,
                                  user: {
                                    id: previousResult.me.user.id,
                                    __typename:
                                      previousResult.me.user.__typename,
                                    followingCollections: {
                                      edges: [
                                        ...previousResult.me.user
                                          .followingCollections.edges
                                      ],
                                      pageInfo,
                                      __typename:
                                        previousResult.me.user
                                          .followingCollections.__typename
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
    background-color: #f5f6f7;
    border-bottom: 1px solid #dddfe2;
    border-radius: 2px 2px 0 0;
    font-weight: bold;
    font-size: 14px !important;
    color: #4b4f56;
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
      followingCollections: Collection[];
    };
  }
>(getFollowedCollections) as OperationOption<{}, {}>;

export default compose(withGetCommunities)(CommunitiesYours);
