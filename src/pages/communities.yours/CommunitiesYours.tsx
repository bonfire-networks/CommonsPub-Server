import * as React from 'react';
import compose from 'recompose/compose';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';

import { Trans } from '@lingui/macro';
import media from 'styled-media-query';

import H4 from '../../components/typography/H4/H4';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
// import Community from '../../types/Community';
import Loader from '../../components/elements/Loader/Loader';
import CommunityCard from '../../components/elements/Community/Community';

const {
  getJoinedCommunitiesQuery
} = require('../../graphql/getJoinedCommunities.graphql');

interface Data extends GraphqlQueryControls {
  me: {
    user: {
      joinedCommunities: {
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
    console.log(this.props.data);
    return (
      <Main>
        <WrapperCont>
          <Wrapper>
            <H4>
              <Trans>Joined Communities</Trans>
            </H4>
            {this.props.data.error ? (
              <span>
                <Trans>Error loading communities</Trans>
              </span>
            ) : this.props.data.loading ? (
              <Loader />
            ) : (
              <>
                <List>
                  {this.props.data.me.user.joinedCommunities.edges.map(
                    (community, i) => (
                      <CommunityCard
                        key={i}
                        summary={community.node.summary}
                        title={community.node.name}
                        collectionsCount={community.node.collections.totalCount}
                        icon={community.node.icon || ''}
                        followed={community.node.followed}
                        id={community.node.localId}
                        externalId={community.node.id}
                        followersCount={community.node.members.totalCount}
                        threadsCount={community.node.threads.totalCount}
                      />
                    )
                  )}
                </List>
                {(this.props.data.me.user.joinedCommunities.pageInfo
                  .startCursor === null &&
                  this.props.data.me.user.joinedCommunities.pageInfo
                    .endCursor === null) ||
                (this.props.data.me.user.joinedCommunities.pageInfo
                  .startCursor &&
                  this.props.data.me.user.joinedCommunities.pageInfo
                    .endCursor === null) ? null : (
                  <LoadMore
                    onClick={() =>
                      this.props.data.fetchMore({
                        variables: {
                          end: this.props.data.me.user.joinedCommunities
                            .pageInfo.endCursor
                        },
                        updateQuery: (previousResult, { fetchMoreResult }) => {
                          const newNodes =
                            fetchMoreResult.me.user.joinedCommunities.edges;
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
                                    __typename:
                                      previousResult.me.user.__typename,
                                    joinedCommunities: {
                                      edges: [
                                        ...previousResult.me.user
                                          .joinedCommunities.edges,
                                        ...newNodes
                                      ],
                                      pageInfo,
                                      __typename:
                                        previousResult.me.user.joinedCommunities
                                          .__typename
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
                                    joinedCommunities: {
                                      edges: [
                                        ...previousResult.me.user
                                          .joinedCommunities.edges
                                      ],
                                      pageInfo,
                                      __typename:
                                        previousResult.me.user.joinedCommunities
                                          .__typename
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
  grid-template-columns: 1fr 1fr 1fr;
  grid-column-gap: 16px;
  grid-row-gap: 16px;
  padding: 16px;
  padding-top: 0;
  background: white;
  ${media.lessThan('medium')`
  grid-template-columns: 1fr;
  `};
`;

const withGetCommunities = graphql<
  {},
  {
    data: {
      me: any;
    };
  }
>(getJoinedCommunitiesQuery, {
  options: (props: Props) => ({
    variables: {
      limit: 15
    }
  })
}) as OperationOption<{}, {}>;

export default compose(withGetCommunities)(CommunitiesYours);
