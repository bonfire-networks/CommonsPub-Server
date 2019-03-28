// View a Community (with list of collections)

import * as React from 'react';
import { compose } from 'recompose';

import { Trans } from '@lingui/macro';
import { Grid } from '@zendeskgarden/react-grid';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import Main from '../../components/chrome/Main/Main';
import Loader from '../../components/elements/Loader/Loader';
import { Tabs, TabPanel } from 'react-tabs';
import CollectionCard from '../../components/elements/Collection/Collection';
import CommunityCard from '../../components/elements/Community/Community';
import { SuperTab, SuperTabList } from '../../components/elements/SuperTab';
const getUserQuery = require('../../graphql/getAgent.graphql');
import { Collection, Community } from '../../components/elements/Icons';
import FollowingCollectionsLoadMore from '../../components/elements/Loadmore/followingCollections';
import JoinedCommunitiesLoadMore from '../../components/elements/Loadmore/joinedCommunities';
import HeroComp from '../Profile/Hero';
import {
  List,
  ListCollections,
  WrapperTab,
  OverlayTab,
  WrapperCont
} from '../Profile';
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
                <HeroComp user={this.props.data.user} />

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
                          <FollowingCollectionsLoadMore
                            collections={
                              this.props.data.user.followingCollections
                            }
                            fetchMore={this.props.data.fetchMore}
                          />
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
                                  followersCount={community.node.followersCount}
                                />
                              )
                            )}
                          </List>
                          <JoinedCommunitiesLoadMore
                            communities={this.props.data.user.joinedCommunities}
                            fetchMore={this.props.data.fetchMore}
                          />
                        </>
                      </TabPanel>
                    </Tabs>
                  </OverlayTab>
                </WrapperTab>
              </WrapperCont>
            )}
          </Grid>
        </Main>
      </>
    );
  }
}

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
