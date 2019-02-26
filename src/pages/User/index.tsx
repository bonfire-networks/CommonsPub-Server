// View a Community (with list of collections)

import * as React from 'react';
import { compose } from 'recompose';

import { Trans } from '@lingui/macro';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
import Loader from '../../components/elements/Loader/Loader';
import { Tabs, TabPanel } from '../../components/chrome/Tabs/Tabs';
import CollectionCard from '../../components/elements/Collection/Collection';
import H2 from '../../components/typography/H2/H2';
import CommunityCard from '../../components/elements/Community/Community';
import P from '../../components/typography/P/P';

const getUserQuery = require('../../graphql/getAgent.graphql');

enum TabsEnum {
  Overview = 'Overview',
  Communities = 'Joined communities',
  Collections = 'Followed collections'
}

interface Data extends GraphqlQueryControls {
  user: {
    name;
    icon;
    summary;
    id;
    localId;
    joinedCommunities: {
      edges: any[];
      totalCount: number;
      pageInfo: {
        startCursor: number;
        endCursor: number;
      };
    };
    followingCollections: {
      edges: any[];
      totalCount: number;
      pageInfo: {
        startCursor: number;
        endCursor: number;
      };
    };
  };
}

interface Props {
  data: Data;
  match: any;
}

type State = {
  tab: TabsEnum;
};

class CommunitiesFeatured extends React.Component<Props, State> {
  state = {
    tab: TabsEnum.Collections
  };
  render() {
    return (
      <>
        <Main>
          <Grid>
            {this.props.data.error ? (
              <span>
                <Trans>Error loading user</Trans>
              </span>
            ) : this.props.data.loading ? (
              <Loader />
            ) : (
              <WrapperCont>
                <HeroCont>
                  <Hero>
                    <Background
                      style={{
                        backgroundImage: `url(https://unsplash.it/800})`
                      }}
                    />
                    <WrapperHero>
                      <Img
                        style={{
                          backgroundImage: `url(${this.props.data.user.icon})`
                        }}
                      />
                      <HeroInfo>
                        <H2>{this.props.data.user.name}</H2>
                        <P>{this.props.data.user.summary}</P>
                      </HeroInfo>
                    </WrapperHero>
                  </Hero>
                </HeroCont>
                <Roww>
                  <Col size={12}>
                    <WrapperTab>
                      <OverlayTab>
                        <Tabs
                          selectedKey={this.state.tab}
                          onChange={tab => this.setState({ tab })}
                        >
                          <TabPanel
                            label={`${TabsEnum.Overview}`}
                            key={TabsEnum.Overview}
                          >
                            <OverviewTab>
                              <Tagline>Description</Tagline>
                            </OverviewTab>
                          </TabPanel>
                          <TabPanel
                            label={`${TabsEnum.Collections}`}
                            key={TabsEnum.Collections}
                          >
                            <>
                              <ListCollections>
                                {this.props.data.user.followingCollections.edges.map(
                                  (comm, i) => (
                                    <CollectionCard
                                      key={i}
                                      collection={comm.node}
                                      communityId={comm.node.localId}
                                    />
                                  )
                                )}
                              </ListCollections>
                              {(this.props.data.user.followingCollections
                                .pageInfo.startCursor &&
                                this.props.data.user.followingCollections
                                  .pageInfo.endCursor === null) ||
                              (this.props.data.user.followingCollections
                                .pageInfo.startCursor === null &&
                                this.props.data.user.followingCollections
                                  .pageInfo.endCursor === null) ? null : (
                                <LoadMore
                                  onClick={() =>
                                    this.props.data.fetchMore({
                                      variables: {
                                        endColl: this.props.data.user
                                          .followingCollections.pageInfo
                                          .endCursor
                                      },
                                      updateQuery: (
                                        previousResult,
                                        { fetchMoreResult }
                                      ) => {
                                        const newNodes =
                                          fetchMoreResult.user
                                            .followingCollections.edges;
                                        const pageInfo =
                                          fetchMoreResult.user
                                            .followingCollections.pageInfo;
                                        return newNodes.length
                                          ? {
                                              // Put the new comments at the end of the list and update `pageInfo`
                                              // so we have the new `endCursor` and `hasNextPage` values

                                              user: {
                                                name: previousResult.user.name,
                                                location:
                                                  previousResult.user.location,
                                                summary:
                                                  previousResult.user.summary,
                                                icon: previousResult.user.icon,
                                                joinedCommunities:
                                                  previousResult.user
                                                    .joinedCommunities,
                                                preferredUsername:
                                                  previousResult.user
                                                    .preferredUsername,
                                                id: previousResult.user.id,
                                                __typename:
                                                  previousResult.user
                                                    .__typename,
                                                followingCollections: {
                                                  edges: [
                                                    ...previousResult.user
                                                      .followingCollections
                                                      .edges,
                                                    ...newNodes
                                                  ],
                                                  pageInfo,
                                                  __typename:
                                                    previousResult.user
                                                      .followingCollections
                                                      .__typename
                                                }
                                              }
                                            }
                                          : {
                                              __typename:
                                                previousResult.__typename,
                                              user: {
                                                id: previousResult.user.id,
                                                name: previousResult.user.name,
                                                location:
                                                  previousResult.user.location,
                                                summary:
                                                  previousResult.user.summary,
                                                icon: previousResult.user.icon,
                                                joinedCommunities:
                                                  previousResult.user
                                                    .joinedCommunities,
                                                preferredUsername:
                                                  previousResult.user
                                                    .preferredUsername,
                                                __typename:
                                                  previousResult.user
                                                    .__typename,
                                                followingCollections: {
                                                  edges: [
                                                    ...previousResult.user
                                                      .followingCollections
                                                      .edges
                                                  ],
                                                  pageInfo,
                                                  __typename:
                                                    previousResult.user
                                                      .followingCollections
                                                      .__typename
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
                          </TabPanel>
                          <TabPanel
                            label={`${TabsEnum.Communities}`}
                            key={TabsEnum.Communities}
                            style={{ height: '100%' }}
                          >
                            <>
                              <List>
                                {this.props.data.user.joinedCommunities.edges.map(
                                  (community, i) => (
                                    <CommunityCard
                                      key={i}
                                      summary={community.node.summary}
                                      title={community.node.name}
                                      collectionsCount={
                                        community.node.collectionsCount
                                      }
                                      icon={community.node.icon || ''}
                                      followed={community.node.followed}
                                      id={community.node.localId}
                                      externalId={community.node.id}
                                      followersCount={
                                        community.node.followersCount
                                      }
                                    />
                                  )
                                )}
                              </List>
                              {(this.props.data.user.joinedCommunities.pageInfo
                                .startCursor === null &&
                                this.props.data.user.joinedCommunities.pageInfo
                                  .endCursor === null) ||
                              (this.props.data.user.joinedCommunities.pageInfo
                                .startCursor &&
                                this.props.data.user.joinedCommunities.pageInfo
                                  .endCursor === null) ? null : (
                                <LoadMore
                                  onClick={() =>
                                    this.props.data.fetchMore({
                                      variables: {
                                        endComm: this.props.data.user
                                          .joinedCommunities.pageInfo.endCursor
                                      },
                                      updateQuery: (
                                        previousResult,
                                        { fetchMoreResult }
                                      ) => {
                                        const newNodes =
                                          fetchMoreResult.user.joinedCommunities
                                            .edges;
                                        const pageInfo =
                                          fetchMoreResult.user.joinedCommunities
                                            .pageInfo;
                                        return newNodes.length
                                          ? {
                                              // Put the new comments at the end of the list and update `pageInfo`
                                              // so we have the new `endCursor` and `hasNextPage` values

                                              user: {
                                                id: previousResult.user.id,
                                                __typename:
                                                  previousResult.user
                                                    .__typename,
                                                joinedCommunities: {
                                                  edges: [
                                                    ...previousResult.user
                                                      .joinedCommunities.edges,
                                                    ...newNodes
                                                  ],
                                                  pageInfo,
                                                  __typename:
                                                    previousResult.user
                                                      .joinedCommunities
                                                      .__typename
                                                }
                                              }
                                            }
                                          : {
                                              user: {
                                                id: previousResult.user.id,
                                                __typename:
                                                  previousResult.user
                                                    .__typename,
                                                joinedCommunities: {
                                                  edges: [
                                                    ...previousResult.user
                                                      .joinedCommunities.edges
                                                  ],
                                                  pageInfo,
                                                  __typename:
                                                    previousResult.user
                                                      .joinedCommunities
                                                      .__typename
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
                          </TabPanel>
                        </Tabs>
                      </OverlayTab>
                    </WrapperTab>
                  </Col>
                </Roww>
              </WrapperCont>
            )}
          </Grid>
        </Main>
      </>
    );
  }
}

const WrapperHero = styled.div`
  margin-top: -50px;

  padding: 24px;

  padding-top: 24px;

  padding-top: 0;

  z-index: 9999;

  position: relative;
`;

const Img = styled.div`
  width: 120px;

  height: 120px;

  border-radius: 100px;

  background: antiquewhite;

  border: 5px solid white;
`;

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

const List = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  grid-column-gap: 16px;
  grid-row-gap: 16px;
  padding: 16px;
  padding-top: 0;
  background: white;
`;

const ListCollections = styled.div`
  display: grid;
  grid-template-columns: 1fr;
  width: 100%;
  background: white;
`;

const HeroCont = styled.div`
  margin-bottom: 16px;
  border-radius: 6px;
  box-sizing: border-box;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
`;

const Roww = styled(Row)`
  height: 100%;
`;

const Tagline = styled.div`
  font-size: 13px;
  letter-spacing: 0.5px;
  font-weight: 700;
  border-bottom: 1px solid #784f56;
  margin-bottom: 18px;
  margin-top: 16px;
  border-bottom: 1px solid #ebedf0;
  color: #4b4f56;
  padding: 12px;
`;

const OverviewTab = styled.div`
  margin-top: -20px;
  & p {
    padding: 0 12px;
  }
`;

const WrapperTab = styled.div`
  display: flex;
  flex: 1;
  height: 100%;
  border-radius: 6px;
  height: 100%;
  box-sizing: border-box;
  border: 5px solid #e2e5ea;
`;
const OverlayTab = styled.div`
  background: #fff;
  height: 100%;
  width: 100%;

  & > div {
    flex: 1;
    height: 100%;
  }
`;

const WrapperCont = styled.div`
  max-width: 1040px;
  margin: 0 auto;
  width: 100%;
  display: flex;
  flex-direction: column;
  margin-bottom: 24px;
  box-sizing: border-box;
`;

const Hero = styled.div`
  width: 100%;
  position: relative;
  background: white;
  border-radius: 6px;
`;

const Background = styled.div`
  margin-top: 24px;
  height: 200px;
  background-size: cover;
  background-repeat: no-repeat;
  background-color: #e6e6e6;
  position: relative;
  margin: 0 auto;
  &:before {
    content: '';
    position: absolute;
    top: 60%;
    right: 0;
    bottom: 0;
    left: 0;
    background-image: linear-gradient(to bottom, #002f4b00, #000);
    opacity: 0.8;
  }
`;

const HeroInfo = styled.div`
  & h2 {
    margin: 0;
    font-size: 24px !important;
    line-height: 40px !important;
    margin-bottom: 16px;
  }

  & button {
    span {
      vertical-align: sub;
      display: inline-block;
      height: 30px;
      margin-right: 4px;
    }
  }
`;

const withGetCollections = graphql<
  {},
  {
    data: {
      user: any;
    };
  }
>(getUserQuery, {
  options: (props: Props) => ({
    variables: {
      id: props.match.id,
      limitComm: 15,
      limitColl: 15
    }
  })
}) as OperationOption<{}, {}>;

export default compose(withGetCollections)(CommunitiesFeatured);
