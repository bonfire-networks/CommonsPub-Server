// View a Community (with list of collections)

import * as React from 'react';
import { compose, withState, withHandlers } from 'recompose';

import { Trans } from '@lingui/macro';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';
import { RouteComponentProps } from 'react-router';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
import Community from '../../types/Community';
import Loader from '../../components/elements/Loader/Loader';
import { Tabs, TabPanel } from '../../components/chrome/Tabs/Tabs';
import Breadcrumb from './breadcrumb';
import { clearFix } from 'polished';
import CollectionCard from '../../components/elements/Collection/Collection';
import P from '../../components/typography/P/P';
import H2 from '../../components/typography/H2/H2';
import H4 from '../../components/typography/H4/H4';
import Button from '../../components/elements/Button/Button';
import Discussion from '../../components/chrome/Discussion/Discussion';
import CommunityModal from '../../components/elements/CommunityModal';
import EditCommunityModal from '../../components/elements/EditCommunityModal';
import Join from './Join';
import { Settings, Users } from '../../components/elements/Icons';
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
  editCommunity(): boolean;
  isEditCommunityOpen: boolean;
}

class CommunitiesFeatured extends React.Component<Props, State> {
  state = {
    tab: TabsEnum.Collections
  };

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
    console.log(community);
    return (
      <>
        <Main>
          <Grid>
            <WrapperCont>
              <Breadcrumb name={community.name} />

              <Hero>
                <Background
                  style={{ backgroundImage: `url(${community.icon})` }}
                />

                <HeroInfo>
                  <H2>{community.name}</H2>
                  <Join
                    id={community.localId}
                    followed={community.followed}
                    externalId={community.id}
                  />
                  {/* {community.followed == false ? null : (
                    <EditButton onClick={this.props.handleNewCollection}>
                      <Edit
                        width={18}
                        height={18}
                        strokeWidth={2}
                        color={'#f98012'}
                      />
                    </EditButton>
                  )} */}
                  {community.localId === 7 ||
                  community.localId === 15 ||
                  community.followed == false ? null : (
                    <EditButton onClick={this.props.editCommunity}>
                      <Settings
                        width={18}
                        height={18}
                        strokeWidth={2}
                        color={'#f98012'}
                      />
                    </EditButton>
                  )}

                  <MembersTot>
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
                        : ''}
                    </Tot>
                  </MembersTot>
                </HeroInfo>
              </Hero>

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
                            <P>
                              {community.summary
                                .split('\n')
                                .map(function(item, key) {
                                  return (
                                    <span key={key}>
                                      {item}
                                      <br />
                                    </span>
                                  );
                                })}
                            </P>
                            <Tagline>Members</Tagline>
                            <Members>
                              {community.members.edges.map((edge, i) => (
                                <Follower key={i}>
                                  <Img
                                    style={{
                                      backgroundImage: `url(${edge.node.icon})`
                                    }}
                                  />
                                  <FollowerName>{edge.node.name}</FollowerName>
                                </Follower>
                              ))}
                            </Members>
                          </OverviewTab>
                        </TabPanel>
                        <TabPanel
                          label={`${TabsEnum.Collections}`}
                          key={TabsEnum.Collections}
                        >
                          <div style={{ display: 'flex', marginTop: '-20px' }}>
                            {collections}
                          </div>
                        </TabPanel>
                        <TabPanel
                          label={`${TabsEnum.Discussion}`}
                          key={TabsEnum.Discussion}
                          style={{ height: '100%' }}
                        >
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
        </Main>
      </>
    );
  }
}

const Roww = styled(Row)`
  height: 100%;
`;

const Tot = styled.div`
  display: inline-block;
  height: 24px;
  line-height: 24px;
  vertical-align: top;
  margin-left: 4px;
  font-size: 13px;
  color: #cacaca;
  font-weight: 600;
`;

const MembersTot = styled.div`
  height: 40px;
  margin-top: 0px;
  font-size: 12px;
  float: right;
  & span {
    margin-right: 16px;

    display: inline-block;

    vertical-align: super;
  }
`;

const ImgTot = styled.div`
  width: 32px;
  height: 32px;
  margin-top: 4px;
  border-radius: 50px;
  display: inline-block;
  margin-left: -4px;
  background-size: cover;
  border: 2px solid white;
`;

const EditButton = styled.span`
  display: inline-block;
  width: 40px;
  height: 40px;
  border: 2px solid #f98012;
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

const Members = styled.div`
  ${clearFix()};
  padding: 0 12px;
`;
const Follower = styled.div`
  float: left;
  margin-right: 8px;
`;
const Img = styled.div`
  width: 40px;
  height: 40px;
  border-radius: 100px;
  margin: 0 auto;
  display: block;
  background-size: cover;
  background-color: #dadada;
`;
const FollowerName = styled(H4)`
  margin-top: 8px !important;
  text-align: center;
  font-size: 15px !important;
  line-height: 20px !important;
  color: #413c4d;
`;

const WrapperTab = styled.div`
  display: flex;
  flex: 1;
  height: 100%;
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
  background: white;
  display: flex;
  flex-direction: column;
  border-radius: 6px;
  box-sizing: border-box;
  border: 5px solid #e2e5ea;
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
  // margin-top: 16px;
  margin-bottom: 16px;
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
  position: absolute;
  z-index: 999;
  bottom: 16px;
  left: 16px;
  right: 16px;
  & h2 {
    margin: 0;
    font-size: 24px !important;
    line-height: 40px !important;
    margin-bottom: 16px;
    color: #fff;
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
      context: parseInt(props.match.params.community)
    }
  })
}) as OperationOption<{}, {}>;

export default compose(
  withGetCollections,
  withState('isOpen', 'onOpen', false),
  withState('isEditCommunityOpen', 'onEditCommunityOpen', false),
  withHandlers({
    handleNewCollection: props => () => props.onOpen(!props.isOpen),
    editCommunity: props => () =>
      props.onEditCommunityOpen(!props.isEditCommunityOpen)
  })
)(CommunitiesFeatured);
