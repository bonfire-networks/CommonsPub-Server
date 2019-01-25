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

enum TabsEnum {
  // Members = 'Members',
  Resources = 'Resources'
  // Discussion = 'Discussion'
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
    console.log(collection);
    // if (collection.comments.length) {
    //   discussions = collection.comments.map(comment => {
    //     let author = {
    //       id: comment.author.id,
    //       name: comment.author.name,
    //       avatarImage: 'https://picsum.photos/200/300'
    //     };
    //     let message = {
    //       body: comment.content,
    //       timestamp: comment.published
    //     };
    //     return <Comment key={comment.id} author={author} comment={message} />;
    //   });
    // } else {
    //   discussions = (
    //     <OverviewCollection>
    //       <P>This community has no discussions yet.</P>
    //       <Button>Start a new thread</Button>
    //     </OverviewCollection>
    //   );
    // }
    if (!collection) {
      // TODO better handling of no collection
      return (
        <span>
          <Trans>Could not load the collection.</Trans>
        </span>
      );
    }

    return (
      <>
        <Main>
          <Grid>
            <Breadcrumb
              community={{
                id: collection.communities[0].localId,
                name: collection.communities[0].name
              }}
              collectionName={collection.name}
            />
            <Row>
              <Hero>
                <Background
                  style={{ backgroundImage: `url(${collection.icon})` }}
                />
                <HeroInfo>
                  <H2>{collection.name}</H2>
                  <P>{collection.summary}</P>
                </HeroInfo>
              </Hero>
            </Row>
            <Row>
              <Col size={12}>
                <WrapperTab>
                  <OverlayTab>
                    <Tabs
                      selectedKey={this.state.tab}
                      onChange={tab => this.setState({ tab })}
                      button={
                        <Button onClick={this.props.editCollection} secondary>
                          <Trans>Edit</Trans>
                        </Button>
                      }
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
                          {resources.length ? (
                            <Wrapper>
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
                              {resources.length > 9 ? null : (
                                <WrapperActions>
                                  <Button onClick={this.props.addNewResource}>
                                    <Trans>Add a new resource</Trans>
                                  </Button>
                                </WrapperActions>
                              )}
                            </Wrapper>
                          ) : (
                            <OverviewCollection>
                              <P>
                                <Trans>This collection has no resources.</Trans>
                              </P>
                              <Button onClick={this.props.addNewResource}>
                                <Trans>Add the first resource</Trans>
                              </Button>
                            </OverviewCollection>
                          )}
                        </div>
                      </TabPanel>
                      {/* <TabPanel
                        label={`${TabsEnum.Discussion} (${
                          collection.comments.length
                        })`}
                        key={TabsEnum.Discussion}
                      >
                        {discussions}
                      </TabPanel> */}
                    </Tabs>
                  </OverlayTab>
                </WrapperTab>
              </Col>
            </Row>
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

const WrapperTab = styled.div`
  padding: 5px;
  border-radius: 0.25em;
  background-color: rgb(232, 232, 232);
  margin: 0 -10px;
  margin-bottom: 16px;
`;
const OverlayTab = styled.div`
  background: #fff;
`;
const HeroInfo = styled.div`
  flex: 1;
  margin-left: 16px;
  & h2 {
    margin: 0;
  }
  & p {
    color: rgba(0, 0, 0, 0.5);
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
  padding: 0 8px;
  margin-bottom: 8px;
  & p {
    margin-top: 0 !important;
  }
`;

const Hero = styled.div`
  display: flex;
  width: 100%;
  position: relative;
  margin-top: 16px;
  margin-bottom: 16px;
`;

const Background = styled.div`
  height: 200px;
  width: 200px;
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
