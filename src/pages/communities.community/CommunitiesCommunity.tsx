// View a Community (with list of collections)

import * as React from 'react';
import { compose, withState, withHandlers } from 'recompose';
import media from 'styled-media-query';
import { Trans } from '@lingui/macro';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';
import { RouteComponentProps } from 'react-router';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
import Community from '../../types/Community';
import Loader from '../../components/elements/Loader/Loader';
import { Tabs, TabPanel } from 'react-tabs';
import '../../containers/App/basic.css';
import Breadcrumb from './breadcrumb';
import { clearFix } from 'polished';
import CollectionCard from '../../components/elements/Collection/Collection';
import P from '../../components/typography/P/P';
import H2 from '../../components/typography/H2/H2';
import Button from '../../components/elements/Button/Button';
import Discussion from '../../components/chrome/Discussion/Discussion';
import CommunityModal from '../../components/elements/CommunityModal';
import EditCommunityModal from '../../components/elements/EditCommunityModal';
import UsersModal from '../../components/elements/UsersModal';
import Join from './Join';
import Link from '../../components/elements/Link/Link';
import moment from 'moment';
import {
  Settings,
  Users,
  Collection,
  Message,
  Eye
} from '../../components/elements/Icons';
const { getCommunityQuery } = require('../../graphql/getCommunity.graphql');
import { SuperTab, SuperTabList } from '../../components/elements/SuperTab';
enum TabsEnum {
  // Overview = 'Overview',
  Collections = 'Collections',
  Discussion = 'Discussion'
}

interface Data extends GraphqlQueryControls {
  community: Community;
}

type State = {
  tab: TabsEnum;
};

interface Props
  extends RouteComponentProps<{
      community: string;
    }> {
  data: Data;
  handleNewCollection: any;
  isOpen: boolean;
  editCommunity(): boolean;
  isEditCommunityOpen: boolean;
  showUsers(boolean): boolean;
  isUsersOpen: boolean;
  document: any;
  stacked: boolean;
  onStacked(boolean): boolean;
}

class CommunitiesFeatured extends React.Component<Props, State> {
  state = {
    tab: TabsEnum.Collections
  };

  // componentDidMount() {
  //   window.addEventListener("scroll", this.resizeHeaderOnScroll);
  //   console.log('test')
  // }
  // resizeHeaderOnScroll() {
  //   console.log('eppppe')
  //   const distanceY = window.pageYOffset || document.documentElement.scrollTop,
  //     shrinkOn = 200,
  //     headerEl:any = document.getElementById("header");

  //   if (distanceY > shrinkOn) {
  //     console.log('eee')
  //     headerEl.setAttribute("view", "small");

  //   } else {
  //     console.log('eeeee')
  //     headerEl.removeAttribute("view");
  //   }
  // }
  render() {
    let collections;
    let community;
    if (this.props.data.error) {
      collections = (
        <span>
          <Trans>Error loading collections</Trans>
        </span>
      );
    } else if (this.props.data.loading) {
      collections = <Loader />;
    } else if (this.props.data.community) {
      community = this.props.data.community;
      if (this.props.data.community.collections.totalCount) {
        collections = (
          <Wrapper>
            <CollectionList>
              {this.props.data.community.collections.edges.map((e, i) => (
                <CollectionCard
                  communityId={this.props.data.community.localId}
                  key={i}
                  collection={e.node}
                />
              ))}
            </CollectionList>
            {community.followed ? (
              <div style={{ padding: '8px' }}>
                <Button onClick={this.props.handleNewCollection}>
                  <Trans>Create a collection</Trans>
                </Button>
              </div>
            ) : (
              <Footer>
                <Trans>Join the community to create a collection</Trans>
              </Footer>
            )}
          </Wrapper>
        );
      } else {
        collections = (
          <OverviewCollection>
            <P>
              <Trans>This community has no collections.</Trans>
            </P>
            {community.followed ? (
              <Button onClick={this.props.handleNewCollection}>
                <Trans>Create the first collection</Trans>
              </Button>
            ) : (
              <Footer>
                <Trans>Join the community to create a collection</Trans>
              </Footer>
            )}
          </OverviewCollection>
        );
      }
    }

    if (!community) {
      return <Loader />;
    }
    return (
      <>
        <Main>
          <Grid>
            <WrapperCont>
              <HeroCont>
                <Breadcrumb name={community.name} />
                <Hero>
                  <Background
                    id="header"
                    style={{ backgroundImage: `url(${community.icon})` }}
                  />
                  <HeroActions>
                    <Join
                      id={community.localId}
                      followed={community.followed}
                      externalId={community.id}
                    />
                    {community.localId === 7 ||
                    community.localId === 15 ||
                    community.followed == false ? null : (
                      <EditButton onClick={this.props.editCommunity}>
                        <Settings
                          width={18}
                          height={18}
                          strokeWidth={2}
                          color={'#fff'}
                        />
                      </EditButton>
                    )}

                    <MembersTot onClick={() => this.props.showUsers(true)}>
                      <span>
                        <Users
                          width={18}
                          height={18}
                          strokeWidth={2}
                          color={'#fff'}
                        />
                      </span>
                      {community.members.edges.slice(0, 3).map((a, i) => {
                        return (
                          <ImgTot
                            key={i}
                            style={{
                              backgroundImage: `url(${a.node.icon ||
                                `https://www.gravatar.com/avatar/${
                                  a.node.localId
                                }?f=y&d=identicon`})`
                            }}
                          />
                        );
                      })}{' '}
                      <Tot>
                        {community.members.totalCount - 3 > 0
                          ? `+ ${community.members.totalCount - 3} More`
                          : ``}
                      </Tot>
                    </MembersTot>
                  </HeroActions>
                  <HeroInfo>
                    <H2>{community.name}</H2>
                    <P>{community.summary}</P>
                  </HeroInfo>
                </Hero>
              </HeroCont>
              <Roww>
                <Col size={12}>
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
                              <Trans>Collections</Trans>
                            </h5>
                          </SuperTab>
                          <SuperTab>
                            <span>
                              <Message
                                width={20}
                                height={20}
                                strokeWidth={2}
                                color={'#a0a2a5'}
                              />
                            </span>{' '}
                            <h5>
                              <Trans>Discussions</Trans>
                            </h5>
                          </SuperTab>
                        </SuperTabList>
                        <TabPanel>
                          <div>
                            {community.inbox.edges.map((t, i) => (
                              <FeedItem key={i}>
                                <Member>
                                  <MemberItem>
                                    <Img alt="user" src={t.node.user.icon} />
                                  </MemberItem>
                                  <MemberInfo>
                                    <h3>
                                      <Link to={'/user/' + t.node.user.localId}>
                                        {t.node.user.name}
                                      </Link>
                                      {t.node.activityType ===
                                      'CreateCollection' ? (
                                        <span>
                                          created the collection{' '}
                                          <Link
                                            to={
                                              `/communities/${
                                                community.localId
                                              }/collections/` +
                                              t.node.object.localId
                                            }
                                          >
                                            {t.node.object.name}
                                          </Link>{' '}
                                        </span>
                                      ) : t.node.activityType ===
                                      'UpdateCommunity' ? (
                                        <span>updated the community</span>
                                      ) : t.node.activityType ===
                                      'UpdateCollection' ? (
                                        <span>
                                          updated the collection{' '}
                                          <Link
                                            to={
                                              `/communities/${
                                                community.localId
                                              }/collections/` +
                                              t.node.object.localId
                                            }
                                          >
                                            {t.node.object.name}
                                          </Link>
                                        </span>
                                      ) : t.node.activityType ===
                                      'JoinCommunity' ? (
                                        <span>joined the community</span>
                                      ) : t.node.activityType ===
                                      'CreateComment' ? (
                                        <span>posted a new comment </span>
                                      ) : t.node.activityType ===
                                      'CreateResource' ? (
                                        <span>
                                          created the resource{' '}
                                          <b>{t.node.object.name}</b> on
                                          collection{' '}
                                          <Link
                                            to={
                                              `/communities/${
                                                community.localId
                                              }/collections/` +
                                              t.node.object.collection.localId
                                            }
                                          >
                                            {t.node.object.collection.name}
                                          </Link>{' '}
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
                            {(community.inbox.pageInfo.startCursor === null &&
                              community.inbox.pageInfo.endCursor === null) ||
                            (community.inbox.pageInfo.startCursor &&
                              community.inbox.pageInfo.endCursor ===
                                null) ? null : (
                              <LoadMore
                                onClick={() =>
                                  this.props.data.fetchMore({
                                    variables: {
                                      end: community.inbox.pageInfo.endCursor
                                    },
                                    updateQuery: (
                                      previousResult,
                                      { fetchMoreResult }
                                    ) => {
                                      console.log(fetchMoreResult);
                                      const newNodes =
                                        fetchMoreResult.community.inbox.edges;
                                      const pageInfo =
                                        fetchMoreResult.community.inbox
                                          .pageInfo;
                                      console.log(newNodes);
                                      return newNodes.length
                                        ? {
                                            // Put the new comments at the end of the list and update `pageInfo`
                                            // so we have the new `endCursor` and `hasNextPage` values
                                            community: {
                                              ...previousResult.community,
                                              __typename:
                                                previousResult.community
                                                  .__typename,
                                              inbox: {
                                                ...previousResult.community
                                                  .inbox,
                                                edges: [
                                                  ...previousResult.community
                                                    .inbox.edges,
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
                                              inbox: {
                                                ...previousResult.community
                                                  .inbox,
                                                edges: [
                                                  ...previousResult.community
                                                    .inbox.edges
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
                        </TabPanel>
                        <TabPanel>
                          <div style={{ display: 'flex' }}>{collections}</div>
                        </TabPanel>
                        <TabPanel>
                          {community.followed ? (
                            <Discussion
                              localId={community.localId}
                              id={community.id}
                              threads={community.threads}
                              followed
                            />
                          ) : (
                            <>
                              <Discussion
                                localId={community.localId}
                                id={community.id}
                                threads={community.threads}
                              />
                              <Footer>
                                <Trans>Join the community to discuss</Trans>
                              </Footer>
                            </>
                          )}
                        </TabPanel>
                      </Tabs>
                    </OverlayTab>
                  </WrapperTab>
                </Col>
              </Roww>
            </WrapperCont>
          </Grid>
          <CommunityModal
            toggleModal={this.props.handleNewCollection}
            modalIsOpen={this.props.isOpen}
            communityId={community.localId}
            communityExternalId={community.id}
          />
          <EditCommunityModal
            toggleModal={this.props.editCommunity}
            modalIsOpen={this.props.isEditCommunityOpen}
            communityId={community.localId}
            communityExternalId={community.id}
            community={community}
          />
          <UsersModal
            toggleModal={this.props.showUsers}
            modalIsOpen={this.props.isUsersOpen}
            members={community.members.edges}
          />
        </Main>
      </>
    );
  }
}

const LoadMore = styled.div`
  height: 50px;
  line-height: 50px;
  text-align: center;
  color: #fff;
  letter-spacing: 0.5px;
  font-size: 14px;
  background: #8fb7ff;
  font-weight: 600;
  cursor: pointer;
  border-radius: 8px;
  margin: 16px;
  &:hover {
    background: #e7e7e7;
  }
`;

const Member = styled.div`
  vertical-align: top;
  margin-right: 14px;
  ${clearFix()};
`;

const MemberInfo = styled.div`
  display: inline-block;
  & h3 {
    font-size: 14px;
    margin: 0;
    color: ${props => props.theme.styles.colour.base2};
    font-weight: 400;
    & span {
      margin: 0 4px;
    }
    & a {
      text-decoration: underline;
      font-weight: 500;
    }
  }
`;

const MemberItem = styled.span`
  background-color: #d6dadc;
  border-radius: 3px;
  color: #4d4d4d;
  display: inline-block;
  height: 42px;
  overflow: hidden;
  position: relative;
  width: 42px;
  user-select: none;
  z-index: 0;
  vertical-align: inherit;
  margin-right: 8px;
`;

const Img = styled.img`
  width: 42px;
  height: 42px;
  display: block;
  -webkit-appearance: none;
  line-height: 42px;
  text-indent: 4px;
  font-size: 13px;
  overflow: hidden;
  max-width: 42px;
  max-height: 42px;
  text-overflow: ellipsis;
  vertical-align: text-top;
  margin-right: 8px;
`;

const Date = styled.div`
  font-size: 12px;
  line-height: 32px;
  height: 20px;
  margin: 0;
  color: ${props => props.theme.styles.colour.base3};
  margin-top: 0px;
  font-weight: 500;
`;

const FeedItem = styled.div`
  min-height: 30px;
  position: relative;
  margin: 0;
  padding: 16px;
  word-wrap: break-word;
  font-size: 14px;
  ${clearFix()};
  transition: background 0.5s ease;
  background: #fff;
  margin-top: 0
  z-index: 10;
  position: relative;
  border-bottom: 1px solid #eaeaea;
`;

const HeroActions = styled.div`
  position: absolute;
  top: 20px;
  position: absolute;
  top: 16px;
  left: 16px;
  right: 16px;
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

const Tot = styled.div`
  float: left;
  height: 24px;
  line-height: 24px;
  vertical-align: middle;
  margin-left: 8px;
  line-height: 32px;
  height: 32px;
  font-size: 13px;
  color: #cacaca;
  font-weight: 600;
`;

const MembersTot = styled.div`
  margin-top: 0px;
  font-size: 12px;
  float: right;
  cursor: pointer;
  padding: 4px 8px;
  &:hover {
    background: #333;
    border-radius: 20px;
  }
  ${clearFix()} & span {
    margin-right: 16px;
    float: left;
    height: 32px;
    line-height: 32px;
    & svg {
      vertical-align: middle;
    }
  }
`;

const ImgTot = styled.div`
  width: 32px;
  height: 32px;
  border-radius: 50px;
  float: left;
  margin-left: -4px;
  background-size: cover;
  border: 2px solid white;
`;

const EditButton = styled.span`
  display: inline-block;
  width: 40px;
  height: 40px;
  vertical-align: bottom;
  margin-left: 8px;
  border-radius: 40px;
  text-align: center;
  cursor: pointer;
  &:hover {
    background: #f9801240;
  }
  & svg {
    margin-top: 8px;
    text-align: center;
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

const Footer = styled.div`
  height: 30px;
  line-height: 30px;
  font-weight: 600;
  text-align: center;
  background: #ffefd9;
  font-size: 13px;
  border-bottom: 1px solid #e4dcc3;
  color: #544f46;
`;

const WrapperCont = styled.div`
  max-width: 1040px;
  margin: 0 auto;
  width: 100%;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
`;

const Wrapper = styled.div`
  flex: 1;
`;

const CollectionList = styled.div`
  flex: 1;
`;

const OverviewCollection = styled.div`
  padding-top: 8px;
  margin-bottom: -8px;
  flex: 1;
  & button {
    margin-left: 8px
    margin-bottom: 16px;
  }
  & p {
    margin-top: 0 !important;
    padding: 8px;
  }
`;

const Hero = styled.div`
  width: 100%;
  position: relative;
`;

const Background = styled.div`
  margin-top: 24px;
  height: 400px;
  background-size: cover;
  background-repeat: no-repeat;
  background-color: #e6e6e6;
  position: relative;
  margin: 0 auto;
  border-bottom-left-radius: 6px;
  border-bottom-right-radius: 6px;
  ${media.lessThan('medium')`
  height: 200px;
`} &:before {
    content: '';
    position: absolute;
    top: 0;
    right: 0;
    border-bottom-left-radius: 6px;
    border-bottom-right-radius: 6px;
    bottom: 0;
    left: 0;
    background-image: linear-gradient(to bottom, #002f4b66, #000);
    opacity: 0.9;
    ${media.lessThan('medium')`
    top: 0%;
  `};
  }
`;

const HeroInfo = styled.div`
  position: absolute;
  z-index: 999;
  bottom: 16px;
  left: 16px;
  right: 16px;
  & h2 {
    margin: 0;
    font-size: 24px !important;
    line-height: 40px !important;
    margin-bottom: 0px;
    color: #f0f0f0;
  }
  & p {
    margin-top: 8px;
    color: #f0f0f0;
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
      community: Community;
    };
  }
>(getCommunityQuery, {
  options: (props: Props) => ({
    variables: {
      limit: 15,
      context: parseInt(props.match.params.community)
    }
  })
}) as OperationOption<{}, {}>;

export default compose(
  withGetCollections,
  withState('isOpen', 'onOpen', false),
  withState('isEditCommunityOpen', 'onEditCommunityOpen', false),
  withState('isUsersOpen', 'showUsers', false),
  withState('stacked', 'onStacked', false),
  withHandlers({
    handleNewCollection: props => () => props.onOpen(!props.isOpen),
    editCommunity: props => () =>
      props.onEditCommunityOpen(!props.isEditCommunityOpen)
  })
)(CommunitiesFeatured);
