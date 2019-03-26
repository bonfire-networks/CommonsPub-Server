// View a Community (with list of collections)

import * as React from 'react';
import { compose } from 'recompose';

import { Trans } from '@lingui/macro';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
import Loader from '../../components/elements/Loader/Loader';
import { Tabs, TabPanel } from 'react-tabs';
import CollectionCard from '../../components/elements/Collection/Collection';
import H2 from '../../components/typography/H2/H2';
import CommunityCard from '../../components/elements/Community/Community';
import P from '../../components/typography/P/P';
import media from 'styled-media-query';
import { SuperTab, SuperTabList } from '../../components/elements/SuperTab';
const getUserQuery = require('../../graphql/getAgent.graphql');
// import { clearFix } from 'polished';
// import moment from 'moment';
// import Link from '../../components/elements/Link/Link';

import { Collection, Community } from '../../components/elements/Icons';
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
    // outbox: {
    //   edges: any[];
    //   totalCount: number;
    //   pageInfo: {
    //     startCursor: number;
    //     endCursor: number;
    //   };
    // };
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
                    {/* <Background
                      style={{
                        backgroundImage: `url(https://unsplash.it/800})`
                      }}
                    /> */}
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
                        <Tabs>
                          <SuperTabList>
                            {/* <SuperTab>
                              <span>
                                <Eye
                                  width={20}
                                  height={20}
                                  strokeWidth={2}
                                  color={'#a0a2a5'}
                                />
                              </span>
                              <h5>
                                <Trans>Timeline</Trans>
                              </h5>
                            </SuperTab> */}
                            <SuperTab>
                              <span>
                                <Collection
                                  width={20}
                                  height={20}
                                  strokeWidth={2}
                                  color={'#a0a2a5'}
                                />
                              </span>
                              <h5>
                                <Trans>Followed Collections</Trans>
                              </h5>
                            </SuperTab>
                            <SuperTab>
                              <span>
                                <Community
                                  width={20}
                                  height={20}
                                  strokeWidth={2}
                                  color={'#a0a2a5'}
                                />
                              </span>{' '}
                              <h5>
                                <Trans>Joined Communities</Trans>
                              </h5>
                            </SuperTab>
                          </SuperTabList>
                          {/* <TabPanel>
                            <div>
                              {this.props.data.user.outbox.edges.map((t, i) => (
                                <FeedItem key={i}>
                                  <Member>
                                    <MemberItem>
                                      <MeImg
                                        alt="user"
                                        src={t.node.user.icon}
                                      />
                                    </MemberItem>
                                    <MemberInfo>
                                      <h3>
                                        <b>{t.node.user.name}</b>
                                        {t.node.activityType ===
                                        'CreateCollection' ? (
                                          <span>
                                            created the collection{' '}
                                            <Link
                                              to={
                                                `/collections/` +
                                                t.node.object.localId
                                              }
                                            >
                                              {t.node.object.name}
                                            </Link>{' '}
                                          </span>
                                        ) : t.node.activityType ===
                                        'UpdateCommunity' ? (
                                          <span>
                                            updated the community{' '}
                                            <Link
                                              to={`/communities/${
                                                t.node.object.localId
                                              }`}
                                            >
                                              {t.node.object.name}
                                            </Link>
                                          </span>
                                        ) : t.node.activityType ===
                                        'UpdateCollection' ? (
                                          <span>
                                            updated the collection{' '}
                                            <Link
                                              to={
                                                `/collections/` +
                                                t.node.object.localId
                                              }
                                            >
                                              {t.node.object.name}
                                            </Link>
                                          </span>
                                        ) : t.node.activityType ===
                                        'JoinCommunity' ? (
                                          <span>
                                            joined the community{' '}
                                            <Link
                                              to={`/communities/${
                                                t.node.object.localId
                                              }`}
                                            >
                                              {t.node.object.name}
                                            </Link>
                                          </span>
                                        ) : t.node.activityType ===
                                        'CreateComment' ? (
                                          <span>
                                            posted a new{' '}
                                            <Link
                                              to={
                                                t.node.object.context
                                                  .__typename === 'Community'
                                                  ? `/communities/${
                                                      t.node.object.context
                                                        .localId
                                                    }/thread/${
                                                      t.node.object.localId
                                                    }`
                                                  : `/collections/${
                                                      t.node.object.context
                                                        .localId
                                                    }/thread/${
                                                      t.node.object.localId
                                                    }`
                                              }
                                            >
                                              comment
                                            </Link>
                                          </span>
                                        ) : t.node.activityType ===
                                        'CreateResource' ? (
                                          <span>
                                            created the resource{' '}
                                            <b>{t.node.object.name}</b> on
                                            collection{' '}
                                            <Link
                                              to={
                                                `/collections/` +
                                                t.node.object.collection.localId
                                              }
                                            >
                                              {t.node.object.collection.name}
                                            </Link>{' '}
                                          </span>
                                        ) : t.node.activityType ===
                                        'FollowCollection' ? (
                                          <span>
                                            started to follow the collection{' '}
                                            <b>{t.node.object.name}</b>
                                          </span>
                                        ) : null}
                                      </h3>
                                      <Date>
                                        {moment(t.node.published).fromNow()}
                                      </Date>
                                    </MemberInfo>
                                  </Member>
                                </FeedItem>
                              ))}
                              {(this.props.data.user.outbox.pageInfo
                                .startCursor === null &&
                                this.props.data.user.outbox.pageInfo
                                  .endCursor === null) ||
                              (this.props.data.user.outbox.pageInfo
                                .startCursor &&
                                this.props.data.user.outbox.pageInfo
                                  .endCursor === null) ? null : (
                                <LoadMore
                                  onClick={() =>
                                    this.props.data.fetchMore({
                                      variables: {
                                        end: this.props.data.user.outbox.pageInfo
                                          .endCursor
                                      },
                                      updateQuery: (
                                        previousResult,
                                        { fetchMoreResult }
                                      ) => {
                                        console.log(fetchMoreResult);
                                        const newNodes =
                                          fetchMoreResult.user.outbox.edges;
                                        const pageInfo =
                                          fetchMoreResult.user.outbox.pageInfo;
                                        console.log(newNodes);
                                        return newNodes.length
                                          ? {
                                              // Put the new comments at the end of the list and update `pageInfo`
                                              // so we have the new `endCursor` and `hasNextPage` values
                                              community: {
                                                ...previousResult.community,
                                                __typename:
                                                  previousResult.user
                                                    .__typename,
                                                outbox: {
                                                  ...previousResult.user.outbox,
                                                  edges: [
                                                    ...previousResult.user.outbox
                                                      .edges,
                                                    ...newNodes
                                                  ]
                                                },
                                                pageInfo
                                              }
                                            }
                                          : {
                                              community: {
                                                ...previousResult.community,
                                                __typename:
                                                  previousResult.community
                                                    .__typename,
                                                outbox: {
                                                  ...previousResult.community
                                                    .outbox,
                                                  edges: [
                                                    ...previousResult.community
                                                      .outbox.edges
                                                  ]
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
                              )}
                            </div>
                          </TabPanel> */}
                          <TabPanel>
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
                                                localId:
                                                  previousResult.user.localId,
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
                                                localId:
                                                  previousResult.user.localId,

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
                                      threadsCount={
                                        community.node.threads.totalCount
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

// const Member = styled.div`
//   vertical-align: top;
//   margin-right: 14px;
//   ${clearFix()};
// `;

// const MemberInfo = styled.div`
//   display: inline-block;
//   & h3 {
//     font-size: 14px;
//     margin: 0;
//     color: ${props => props.theme.styles.colour.base2};
//     font-weight: 400;
//     & span {
//       margin: 0 4px;
//     }
//     & a {
//       text-decoration: underline;
//       font-weight: 500;
//     }
//   }
// `;

// const MemberItem = styled.span`
//   background-color: #d6dadc;
//   border-radius: 3px;
//   color: #4d4d4d;
//   display: inline-block;
//   height: 42px;
//   overflow: hidden;
//   position: relative;
//   width: 42px;
//   user-select: none;
//   z-index: 0;
//   vertical-align: inherit;
//   margin-right: 8px;
// `;

// const MeImg = styled.img`
//   width: 42px;
//   height: 42px;
//   display: block;
//   -webkit-appearance: none;
//   line-height: 42px;
//   text-indent: 4px;
//   font-size: 13px;
//   overflow: hidden;
//   max-width: 42px;
//   max-height: 42px;
//   text-overflow: ellipsis;
//   vertical-align: text-top;
//   margin-right: 8px;
// `;

// const Date = styled.div`
//   font-size: 12px;
//   line-height: 32px;
//   height: 20px;
//   margin: 0;
//   color: ${props => props.theme.styles.colour.base3};
//   margin-top: 0px;
//   font-weight: 500;
// `;

// const FeedItem = styled.div`
//   min-height: 30px;
//   position: relative;
//   margin: 0;
//   padding: 16px;
//   word-wrap: break-word;
//   font-size: 14px;
//   ${clearFix()};
//   transition: background 0.5s ease;
//   background: #fff;
//   margin-top: 0
//   z-index: 10;
//   position: relative;
//   border-bottom: 1px solid #eaeaea;
// `;

const WrapperHero = styled.div`
  // margin-top: -50px;
  padding: 24px;
  padding-top: 0;
  z-index: 9999;
  position: relative;
  text-align: center;
`;

const Img = styled.div`
  width: 120px;
  height: 120px;
  border-radius: 100px;
  background: antiquewhite;
  border: 5px solid white;
  margin: 0 auto;
  margin-bottom: 10px;
  background-size: cover;
  background-position: center center;
  background-repeat: no-repeat;
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

  ${media.lessThan('medium')`
  grid-template-columns: 1fr;
  grid-column-gap: 0px;
`};
`;

const ListCollections = styled.div`
  display: grid;
  grid-template-columns: 1fr;
  width: 100%;
  background: white;
`;

const HeroCont = styled.div`
  margin-bottom: 16px;
  // border-radius: 6px;
  box-sizing: border-box;
  // box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
`;

const Roww = styled(Row)`
  height: 100%;
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
  // background: white;
  // border-radius: 6px;
`;

// const Background = styled.div`
//   margin-top: 24px;
//   height: 200px;
//   background-size: cover;
//   background-repeat: no-repeat;
//   background-color: #e6e6e6;
//   position: relative;
//   margin: 0 auto;
//   &:before {
//     content: '';
//     position: absolute;
//     top: 60%;
//     right: 0;
//     bottom: 0;
//     left: 0;
//     background-image: linear-gradient(to bottom, #002f4b00, #000);
//     opacity: 0.8;
//     ${media.lessThan('medium')`
//     top: 10%;
//   `};
//   }
// `;

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
      id: Number(props.match.params.id),
      limitComm: 15,
      limitColl: 15
    }
  })
}) as OperationOption<{}, {}>;

export default compose(withGetCollections)(CommunitiesFeatured);
