// View a Collection (with list of resources)

import * as React from 'react';

import { Trans } from '@lingui/macro';

import { Grid, Row, Col } from '@zendeskgarden/react-grid';
// import H4 from '../../components/typography/H4/H4';
import P from '../../components/typography/P/P';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
import { Tabs, TabPanel } from '../../components/chrome/Tabs/Tabs';
// import { ResourceCard } from "../../components/elements/Card/Card";
import ResourceCard from '../../components/elements/Resource/Resource';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import Collection from '../../types/Collection';
import { compose, withState, withHandlers } from 'recompose';
import { RouteComponentProps } from 'react-router';
import Loader from '../../components/elements/Loader/Loader';
import Breadcrumb from './breadcrumb';
import Button from '../../components/elements/Button/Button';
// import Comment from '../../components/elements/Comment/Comment';
import CollectionModal from '../../components/elements/CollectionModal';
import EditCollectionModal from '../../components/elements/EditCollectionModal';
const getCollection = require('../../graphql/getCollection.graphql');
import H2 from '../../components/typography/H2/H2';
import Join from '../../components/elements/Collection/Join';
import Discussion from '../../components/chrome/Discussion/Discussion';
import { Settings } from '../../components/elements/Icons';

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

    console.log(collection.communities[0]);
    let community_name = collection.communities[0].name;

    return (
      <>
        <Main>
          <Grid>
            <WrapperCont>
              <Breadcrumb
                community={{
                  id: collection.communities[0].localId,
                  name: collection.communities[0].name
                }}
                collectionName={collection.name}
              />
              <Hero>
                <Background
                  style={{ backgroundImage: `url(${collection.icon})` }}
                />
                <HeroInfo>
                  <H2>{collection.name}</H2>
                  <P>{collection.summary}</P>
                  <ActionsHero>
                    <HeroJoin>
                      <Join
                        followed={collection.followed}
                        id={collection.localId}
                        externalId={collection.id}
                      />
                    </HeroJoin>
                    {collection.communities[0].followed ? (
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
              <Row>
                <Col size={12}>
                  <WrapperTab>
                    <OverlayTab>
                      <Tabs
                        selectedKey={this.state.tab}
                        onChange={tab => this.setState({ tab })}
                      >
                        {/* <TabPanel
                        label={`${TabsEnum.Members} (${
                          collection.followersCount
                        })`}
                        key={TabsEnum.Members}
                        >
                        <Members>
                        {collection.followers.map((user, i) => (
                          <Follower key={i}>
                          <Img
                          style={{ backgroundImage: `url(${user.icon})` }}
                          />
                          <FollowerName>{user.name}</FollowerName>
                          </Follower>
                          ))}
                          </Members>
                        </TabPanel> */}
                        <TabPanel
                          label={`${TabsEnum.Resources} (${
                            collection.resources.length
                          }/10)`}
                          key={TabsEnum.Resources}
                        >
                          <div style={{ display: 'flex', flexWrap: 'wrap' }}>
                            <Wrapper>
                              {resources.length ? (
                                <CollectionList>
                                  {resources.map((resource, i) => (
                                    <ResourceCard
                                      key={i}
                                      icon={resource.icon}
                                      title={resource.name}
                                      summary={resource.summary}
                                      url={resource.url}
                                      localId={resource.localId}
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

                              {resources.length > 9 ? null : collection
                                .communities[0].followed ? (
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
                        <TabPanel
                          label={`${TabsEnum.Discussion}`}
                          key={TabsEnum.Discussion}
                        >
                          {collection.communities[0].followed ? (
                            <Discussion
                              localId={collection.localId}
                              id={collection.id}
                            />
                          ) : (
                            <Footer>
                              <Trans>
                                Join the <strong>{community_name}</strong>{' '}
                                community to participate in discussions
                              </Trans>
                            </Footer>
                          )}
                        </TabPanel>
                      </Tabs>
                    </OverlayTab>
                  </WrapperTab>
                </Col>
              </Row>
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
  background: white;
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
const WrapperTab = styled.div``;
const OverlayTab = styled.div`
  background: #fff;
`;
const HeroInfo = styled.div`
  flex: 1;
  margin-left: 16px;
  & h2 {
    margin: 0;
    line-height: 32px !important;
    font-size: 24px !important;
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

const WrapperActions = styled.div`
  margin: 8px;
`;

const Wrapper = styled.div`
  flex: 1;
  margin-top: -20px;
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
`;

const Background = styled.div`
  height: 120px;
  width: 120px;
  border-radius: 4px;
  background-size: cover;
  background-repeat: no-repeat;
  background-color: #e6e6e6;
  position: relative;
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
