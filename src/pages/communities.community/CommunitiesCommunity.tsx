import * as React from 'react';
import { compose, withState, withHandlers } from 'recompose';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';
import { RouteComponentProps } from 'react-router';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import styled from 'styled-components';

import Main from '../../components/chrome/Main/Main';
// import P from '../../components/typography/P/P';
import Community from '../../types/Community';
import Loader from '../../components/elements/Loader/Loader';
import { Tabs, TabPanel } from '../../components/chrome/Tabs/Tabs';
import Breadcrumb from './breadcrumb';
// import { CollectionCard } from '../../components/elements/Card/Card';
import CollectionCard from '../../components/elements/Collection/Collection';
import H6 from '../../components/typography/H6/H6';
import P from '../../components/typography/P/P';
import Button from '../../components/elements/Button/Button';
import Comment from '../../components/elements/Comment/Comment';
import CommunityModal from '../../components/elements/CommunityModal';

const { getCommunityQuery } = require('../../graphql/getCommunity.graphql');

enum TabsEnum {
  Overview = 'Overview',
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
}

class CommunitiesFeatured extends React.Component<Props, State> {
  state = {
    tab: TabsEnum.Collections
  };

  render() {
    let collections;
    let community;
    let comments;
    if (this.props.data.error) {
      console.error(this.props.data.error);
      collections = <span>Error loading collections</span>;
      comments = <span>Error loading comments</span>;
    } else if (this.props.data.loading) {
      collections = <Loader />;
      comments = <Loader />;
    } else if (this.props.data.community) {
      community = this.props.data.community;

      if (this.props.data.community.collections.length) {
        collections = (
          <Wrapper>
            <CollectionList>
              {this.props.data.community.collections.map((collection, i) => (
                <CollectionCard
                  communityId={this.props.data.community.localId}
                  key={i}
                  collection={collection}
                />
              ))}
            </CollectionList>
            <Button onClick={this.props.handleNewCollection}>
              Create a new collection
            </Button>
          </Wrapper>
        );
      } else {
        collections = (
          <OverviewCollection>
            <P>This community has no collections.</P>
            <Button onClick={this.props.handleNewCollection}>
              Create the first collection
            </Button>
          </OverviewCollection>
        );
      }
      if (this.props.data.community.comments.length) {
        comments = this.props.data.community.comments.map(comment => {
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
        comments = (
          <OverviewCollection>
            <P>This community has no discussions yet.</P>
            <Button>Start a new thread</Button>
          </OverviewCollection>
        );
      }
    }

    if (!community) {
      return <Loader />;
    }
    console.log(community);
    return (
      <>
        <Main>
          <Grid>
            <Breadcrumb name={community.name} />
            <Row>
              <Hero>
                <Background
                  style={{ backgroundImage: `url(${community.image})` }}
                >
                  <Title>{community.name}</Title>
                </Background>
                <Tabs
                  selectedKey={this.state.tab}
                  onChange={tab => this.setState({ tab })}
                >
                  <TabPanel label={TabsEnum.Overview} key={TabsEnum.Overview}>
                    <div style={{ display: 'flex' }}>
                      <WrapperBox>
                        <H6>Summary</H6>
                        <P>{community.summary}</P>
                      </WrapperBox>
                    </div>
                  </TabPanel>
                  <TabPanel
                    label={TabsEnum.Collections}
                    key={TabsEnum.Collections}
                  >
                    <div style={{ display: 'flex' }}>{collections}</div>
                  </TabPanel>
                  <TabPanel
                    label={TabsEnum.Discussion}
                    key={TabsEnum.Discussion}
                  >
                    {comments}
                  </TabPanel>
                </Tabs>
              </Hero>
            </Row>
            <Row>
              <Col size={12} />
            </Row>
          </Grid>
          <CommunityModal
            toggleModal={this.props.handleNewCollection}
            modalIsOpen={this.props.isOpen}
            communityId={community.localId}
            communityExternalId={community.id}
          />
        </Main>
      </>
    );
  }
}

const Wrapper = styled.div`
  flex: 1;
`;

const CollectionList = styled.div`
  flex: 1;
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

const OverviewCollection = styled.div`
  padding: 0 8px;
  margin-bottom: 8px;
  & p {
    margin-top: 0 !important;
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
      context: parseInt(props.match.params.community)
    }
  })
}) as OperationOption<{}, {}>;

export default compose(
  withGetCollections,
  withState('isOpen', 'onOpen', false),
  withHandlers({
    handleNewCollection: props => () => props.onOpen(!props.isOpen)
  })
)(CommunitiesFeatured);
