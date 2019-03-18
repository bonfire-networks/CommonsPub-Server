// View a Collection (with list of resources)

import * as React from 'react';

import { Trans } from '@lingui/macro';

import { Grid, Row, Col } from '@zendeskgarden/react-grid';
import P from '../../components/typography/P/P';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
import ResourceCard from '../../components/elements/Resource/Resource';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import Collection from '../../types/Collection';
import { compose, withState, withHandlers } from 'recompose';
import { RouteComponentProps } from 'react-router';
import Loader from '../../components/elements/Loader/Loader';
import Breadcrumb from './breadcrumb';
import Button from '../../components/elements/Button/Button';
import CollectionModal from '../../components/elements/CollectionModal';
import EditCollectionModal from '../../components/elements/EditCollectionModal';
const getCollection = require('../../graphql/getCollection.graphql');
import H2 from '../../components/typography/H2/H2';
import { clearFix } from 'polished';
import Join from '../../components/elements/Collection/Join';
import Discussion from '../../components/chrome/Discussion/DiscussionCollection';
import {
  Settings,
  Eye,
  Resource,
  Message
} from '../../components/elements/Icons';
import { SuperTab, SuperTabList } from '../../components/elements/SuperTab';
import { Tabs, TabPanel } from 'react-tabs';
import Link from '../../components/elements/Link/Link';
import moment from 'moment';
import media from 'styled-media-query';

enum TabsEnum {
  // Members = 'Members',
  Resources = 'Resources',
  Discussion = 'Discussion'
}

interface Data extends GraphqlQueryControls {
  collection: Collection;
}

interface Props
  extends RouteComponentProps<{
      community: string;
      collection: string;
    }> {
  data: Data;
  addNewResource(): boolean;
  isOpen: boolean;
  editCollection(): boolean;
  isEditCollectionOpen: boolean;
}

class CollectionComponent extends React.Component<Props> {
  state = {
    tab: TabsEnum.Resources
  };

  render() {
    let collection;
    let resources;
    // let discussions;
    if (this.props.data.error) {
      collection = null;
    } else if (this.props.data.loading) {
      return <Loader />;
    } else {
      collection = this.props.data.collection;
      resources = this.props.data.collection.resources;
    }
    if (!collection) {
      // TODO better handling of no collection
      return (
        <span>
          <Trans>Could not load the collection.</Trans>
        </span>
      );
    }

    let community_name = collection.community.name;

    return (
      <>
        <Main>
          <Grid>
            <WrapperCont>
              <HeroCont>
                <Breadcrumb
                  community={{
                    id: collection.community.localId,
                    name: collection.community.name
                  }}
                  collectionName={collection.name}
                />
                <Hero>
                  <Background
                    style={{ backgroundImage: `url(${collection.icon})` }}
                  />
                  <HeroInfo>
                    <H2>{collection.name}</H2>
                    <P>
                      {collection.summary.split('\n').map(function(item, key) {
                        return (
                          <span key={key}>
                            {item}
                            <br />
                          </span>
                        );
                      })}
                    </P>
                    <ActionsHero>
                      <HeroJoin>
                        <Join
                          followed={collection.followed}
                          id={collection.localId}
                          externalId={collection.id}
                        />
                      </HeroJoin>
                      {collection.community.followed ? (
                        <EditButton onClick={this.props.editCollection}>
                          <Settings
                            width={18}
                            height={18}
                            strokeWidth={2}
                            color={'#f98012'}
                          />
                          <Trans>Edit collection</Trans>
                        </EditButton>
                      ) : null}
                    </ActionsHero>
                  </HeroInfo>
                </Hero>
                <Actions />
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
                              <Resource
                                width={20}
                                height={20}
                                strokeWidth={2}
                                color={'#a0a2a5'}
                              />
                            </span>
                            <h5>
                              <Trans>Resources</Trans> (
                              {collection.resources.totalCount}
                              /10)
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
                            {collection.inbox.edges.map((t, i) => (
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
                                                collection.localId
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
                                                collection.localId
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
                                          <b>{t.node.object.name}</b>
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
                            {(collection.inbox.pageInfo.startCursor === null &&
                              collection.inbox.pageInfo.endCursor === null) ||
                            (collection.inbox.pageInfo.startCursor &&
                              collection.inbox.pageInfo.endCursor ===
                                null) ? null : (
                              <LoadMore
                                onClick={() =>
                                  this.props.data.fetchMore({
                                    variables: {
                                      end: collection.inbox.pageInfo.endCursor
                                    },
                                    updateQuery: (
                                      previousResult,
                                      { fetchMoreResult }
                                    ) => {
                                      console.log(fetchMoreResult);
                                      const newNodes =
                                        fetchMoreResult.collection.inbox.edges;
                                      const pageInfo =
                                        fetchMoreResult.collection.inbox
                                          .pageInfo;
                                      console.log(newNodes);
                                      return newNodes.length
                                        ? {
                                            // Put the new comments at the end of the list and update `pageInfo`
                                            // so we have the new `endCursor` and `hasNextPage` values
                                            collection: {
                                              ...previousResult.collection,
                                              __typename:
                                                previousResult.collection
                                                  .__typename,
                                              inbox: {
                                                ...previousResult.collection
                                                  .inbox,
                                                edges: [
                                                  ...previousResult.collection
                                                    .inbox.edges,
                                                  ...newNodes
                                                ]
                                              },
                                              pageInfo
                                            }
                                          }
                                        : {
                                            collection: {
                                              ...previousResult.collection,
                                              __typename:
                                                previousResult.collection
                                                  .__typename,
                                              inbox: {
                                                ...previousResult.collection
                                                  .inbox,
                                                edges: [
                                                  ...previousResult.collection
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
                          <div
                            style={{
                              display: 'flex',
                              flexWrap: 'wrap',
                              background: '#e9ebef'
                            }}
                          >
                            <Wrapper>
                              {resources.totalCount ? (
                                <CollectionList>
                                  {resources.edges.map((edge, i) => (
                                    <ResourceCard
                                      key={i}
                                      icon={edge.node.icon}
                                      title={edge.node.name}
                                      summary={edge.node.summary}
                                      url={edge.node.url}
                                      localId={edge.node.localId}
                                    />
                                  ))}
                                </CollectionList>
                              ) : (
                                <OverviewCollection>
                                  <P>
                                    <Trans>
                                      This collection has no resources.
                                    </Trans>
                                  </P>
                                  {/* <Button onClick={this.props.addNewResource}>
                                  <Trans>Add the first resource</Trans>
                                </Button> */}
                                </OverviewCollection>
                              )}

                              {resources.totalCount > 9 ? null : collection
                                .community.followed ? (
                                <WrapperActions>
                                  <Button onClick={this.props.addNewResource}>
                                    <Trans>Add a new resource</Trans>
                                  </Button>
                                </WrapperActions>
                              ) : (
                                <Footer>
                                  <Trans>
                                    Join the <strong>{community_name}</strong>{' '}
                                    community to add a resource
                                  </Trans>
                                </Footer>
                              )}
                            </Wrapper>
                          </div>
                        </TabPanel>
                        <TabPanel>
                          {collection.community.followed ? (
                            <Discussion
                              localId={collection.localId}
                              id={collection.id}
                              threads={collection.threads}
                              followed
                            />
                          ) : (
                            <>
                              <Discussion
                                localId={collection.localId}
                                id={collection.id}
                                threads={collection.threads}
                              />
                              <Footer>
                                <Trans>
                                  Join the <strong>{community_name}</strong>{' '}
                                  community to participate in discussions
                                </Trans>
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
          <CollectionModal
            toggleModal={this.props.addNewResource}
            modalIsOpen={this.props.isOpen}
            collectionId={collection.localId}
            collectionExternalId={collection.id}
          />
          <EditCollectionModal
            toggleModal={this.props.editCollection}
            modalIsOpen={this.props.isEditCollectionOpen}
            collectionId={collection.localId}
            collectionExternalId={collection.id}
            collection={collection}
          />
        </Main>
      </>
    );
  }
}

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

const ActionsHero = styled.div`
  margin-top: 4px;
  & div {
    &:hover {
      background: transparent;
    }
  }
`;
const HeroJoin = styled.div`
  float: left;
`;

const Roww = styled(Row)`
  height: 100%;
`;

const Actions = styled.div``;
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
  // height: 100%;

  box-sizing: border-box;
`;
// const Members = styled.div`
//   display: grid;
//   grid-template-columns: 1fr 1fr 1fr 1fr;
//   grid-column-gap: 8px;
//   grid-row-gap: 8px;
// `;
// const Follower = styled.div``;
// const Img = styled.div`
//   width: 40px;
//   height: 40px;
//   border-radius: 100px;
//   margin: 0 auto;
//   display: block;
// `;
// const FollowerName = styled(H4)`
//   margin-top: 8px;
//   text-align: center;
// `;

const EditButton = styled.span`
  color: #ff9d00;
  height: 40px;
  font-weight: 600;
  font-size: 13px;
  line-height: 38px;
  margin-left: 24px;
  cursor: pointer;
  display: inline-block;
  & svg {
    margin-top: 8px;
    text-align: center;
    vertical-align: text-bottom;
    margin-right: 8px;
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
const HeroInfo = styled.div`
  flex: 1;
  margin-left: 16px;
  & h2 {
    margin: 0;
    line-height: 32px !important;
    font-size: 24px !important;

    ${media.lessThan('medium')`
      margin-top: 8px;
    `};
  }
  & p {
    margin: 0;
    color: rgba(0, 0, 0, 0.8);
    font-size: 15px;
    margin-top: 8px;
  }
  & div {
    text-align: left;
    padding: 0;
  }
`;
const HeroCont = styled.div`
  margin-bottom: 16px;
  border-radius: 6px;
  box-sizing: border-box;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  background: #fff;
`;

const WrapperActions = styled.div`
  margin: 8px;
  & button {
    ${media.lessThan('medium')`
   width: 100%;
    `};
  }
`;

const Wrapper = styled.div`
  flex: 1;
`;

const CollectionList = styled.div`
  flex: 1;
  margin: 10px;
`;

const OverviewCollection = styled.div`
  padding: 8px;
  & p {
    margin-top: 14px !important;
    font-size: 14px;
  }
`;

const Hero = styled.div`
  display: flex;
  width: 100%;
  position: relative;
  padding: 16px;
  ${media.lessThan('medium')`
  text-align: center;
  display: block;
`};
`;

const Background = styled.div`
  height: 120px;
  width: 120px;
  border-radius: 4px;
  background-size: cover;
  background-repeat: no-repeat;
  background-color: #e6e6e6;
  position: relative;
  margin: 0 auto;
`;

const withGetCollection = graphql<
  {},
  {
    data: {
      collection: Collection;
    };
  }
>(getCollection, {
  options: (props: Props) => ({
    variables: {
      limit: 15,
      id: Number(props.match.params.collection)
    }
  })
}) as OperationOption<{}, {}>;

export default compose(
  withGetCollection,
  withState('isOpen', 'onOpen', false),
  withState('isEditCollectionOpen', 'onEditCollectionOpen', false),
  withHandlers({
    addNewResource: props => () => props.onOpen(!props.isOpen),
    editCollection: props => () =>
      props.onEditCollectionOpen(!props.isEditCollectionOpen)
  })
)(CollectionComponent);
