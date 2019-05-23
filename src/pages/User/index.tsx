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
import { Collection, Community, Eye } from '../../components/elements/Icons';
import FollowingCollectionsLoadMore from '../../components/elements/Loadmore/followingCollections';
import JoinedCommunitiesLoadMore from '../../components/elements/Loadmore/joinedCommunities';
import HeroComp from '../Profile/Hero';
import { WrapperTab, OverlayTab } from '../communities.community/Community';
import { List, ListCollections, WrapperCont } from '../Profile';
import TimelineItem from '../../components/elements/TimelineItem';
import LoadMoreTimeline from '../../components/elements/Loadmore/timelineoutbox';

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
    location;
    preferredUsername;
    localId;
    outbox: {
      edges: any[];
      totalCount: number;
      pageInfo: {
        startCursor: number;
        endCursor: number;
      };
    };
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
                        <SuperTab>
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
                        </SuperTab>
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
                      <TabPanel>
                        <div>
                          {this.props.data.user.outbox.edges.map((t, i) => (
                            <TimelineItem
                              node={t.node}
                              user={t.node.user}
                              key={i}
                            />
                          ))}
                          <div style={{ padding: '8px' }}>
                            <LoadMoreTimeline
                              fetchMore={this.props.data.fetchMore}
                              community={this.props.data.user}
                            />
                          </div>
                        </div>
                      </TabPanel>
                      <TabPanel>
                        <>
                          <ListCollections>
                            {this.props.data.user.followingCollections.edges.map(
                              (comm, i) => (
                                <CollectionCard
                                  key={i}
                                  collection={comm.node}
                                />
                              )
                            )}
                          </ListCollections>
                          <div style={{ padding: '8px' }}>
                            <FollowingCollectionsLoadMore
                              collections={
                                this.props.data.user.followingCollections
                              }
                              fetchMore={this.props.data.fetchMore}
                            />
                          </div>
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
                          <div style={{ padding: '8px' }}>
                            <JoinedCommunitiesLoadMore
                              communities={
                                this.props.data.user.joinedCommunities
                              }
                              fetchMore={this.props.data.fetchMore}
                            />
                          </div>
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
    fetchPolicy: 'no-cache',
    variables: {
      id: Number(props.match.params.id),
      limitComm: 15,
      limitColl: 15,
      limitTimeline: 15
    }
  })
}) as OperationOption<{}, {}>;

export default compose(withGetCollections)(CommunitiesFeatured);
