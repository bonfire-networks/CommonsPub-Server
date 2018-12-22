import * as React from 'react';
import { Grid, Row } from '@zendeskgarden/react-grid';
import H6 from '../../components/typography/H6/H6';
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
import Comment from '../../components/elements/Comment/Comment';
import CollectionModal from '../../components/elements/CollectionModal';
const getCollection = require('../../graphql/getCollection.graphql');

enum TabsEnum {
  Overview = 'Overview',
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
}

class CollectionComponent extends React.Component<Props> {
  state = {
    tab: TabsEnum.Resources
  };

  render() {
    let collection;
    let resources;
    let discussions;
    console.log(this.props.match.params);
    if (this.props.data.error) {
      console.error(this.props.data.error);
      collection = null;
    } else if (this.props.data.loading) {
      return <Loader />;
    } else {
      collection = this.props.data.collection;
      resources = this.props.data.collection.resources;
    }
    if (collection.comments.length) {
      discussions = collection.comments.map(comment => {
        let author = {
          id: comment.author.id,
          name: comment.author.name,
          avatarImage: 'https://picsum.photos/200/300'
        };
        let message = {
          body: comment.content,
          timestamp: comment.published
        };
        return <Comment key={comment.id} author={author} comment={message} />;
      });
    } else {
      discussions = (
        <OverviewCollection>
          <P>This community has no discussions yet.</P>
          <Button>Start a new thread</Button>
        </OverviewCollection>
      );
    }
    console.log(this.props.data);
    if (!collection) {
      // TODO better handling of no collection
      return <span>Could not load collection.</span>;
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
                >
                  <Title>{collection.name}</Title>
                </Background>
                <Tabs
                  selectedKey={this.state.tab}
                  onChange={tab => this.setState({ tab })}
                >
                  <TabPanel label={TabsEnum.Overview} key={TabsEnum.Overview}>
                    <div style={{ display: 'flex' }}>
                      <WrapperBox>
                        <H6>Summary</H6>
                        <P>{collection.content}</P>
                      </WrapperBox>
                    </div>
                  </TabPanel>
                  <TabPanel label={TabsEnum.Resources} key={TabsEnum.Resources}>
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
                              />
                            ))}
                          </CollectionList>
                          <WrapperActions>
                            <Button onClick={this.props.addNewResource}>
                              Add a new resource
                            </Button>
                          </WrapperActions>
                        </Wrapper>
                      ) : (
                        <OverviewCollection>
                          <P>This community has no resources.</P>
                          <Button onClick={this.props.addNewResource}>
                            Add the first resource
                          </Button>
                        </OverviewCollection>
                      )}
                    </div>
                  </TabPanel>
                  <TabPanel
                    label={TabsEnum.Discussion}
                    key={TabsEnum.Discussion}
                  >
                    {discussions}
                  </TabPanel>
                </Tabs>
              </Hero>
            </Row>
          </Grid>
          <CollectionModal
            toggleModal={this.props.addNewResource}
            modalIsOpen={this.props.isOpen}
            collectionId={collection.localId}
            collectionExternalId={collection.id}
          />
        </Main>
      </>
    );
  }
}

const WrapperActions = styled.div`
  margin: 8px;
`;

const Wrapper = styled.div`
  flex: 1;
  margin-top: -20px;
`;

const CollectionList = styled.div`
  flex: 1;
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  grid-column-gap: 8px;
  grid-row-gap: 8px;
  margin: 10px;
`;

const OverviewCollection = styled.div`
  padding: 0 8px;
  margin-bottom: 8px;
  & p {
    margin-top: 0 !important;
  }
`;

const WrapperBox = styled.div`
  padding: 0 8px;
  & h6 {
    margin: 0 !important;
  }
  & p {
    margin-top: 8px !important;
  }
`;

const Hero = styled.div`
  box-shadow: 0 1px 2px 0 rgba(255, 255, 255, 0.1);
  background: #fff;
  border: 1px solid #f3f3f3;
  border-radius: 4px;
  width: 100%;
  position: relative;
  margin-top: 16px;
`;

const Background = styled.div`
  height: 200px;
  background-size: cover;
  background-repeat: no-repeat;
  background-color: #f8f8f8;
  position: relative;
  &:after {
    position: absolute;
    content: '';
    background: rgb(0, 0, 0);
    background: linear-gradient(
      180deg,
      rgba(0, 0, 0, 0) 0%,
      rgba(0, 0, 0, 1) 100%
    );
    display: block;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
  }
`;

const Title = styled.div`
  position: absolute;
  bottom: 20px;
  left: 30px;
  color: #fff;
  z-index: 9;
  font-size: 24px;
  font-weight: 700;
  letter-spacing: 1px;
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
  withHandlers({
    addNewResource: props => () => props.onOpen(!props.isOpen)
  })
)(CollectionComponent);
