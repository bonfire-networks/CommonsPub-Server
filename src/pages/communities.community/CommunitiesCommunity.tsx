// View a Community (with list of collections)

import * as React from 'react';
import { compose, withState, withHandlers } from 'recompose';
import media from 'styled-media-query';
import { Trans } from '@lingui/macro';
import { Grid } from '@zendeskgarden/react-grid';
import { RouteComponentProps } from 'react-router';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
import Community from '../../types/Community';
import Loader from '../../components/elements/Loader/Loader';
import '../../containers/App/basic.css';
import Breadcrumb from './breadcrumb';
import { clearFix } from 'polished';
import CollectionCard from '../../components/elements/Collection/Collection';
import P from '../../components/typography/P/P';
import H2 from '../../components/typography/H2/H2';
// import Button from "../../components/elements/Button/Button";
import CommunityModal from '../../components/elements/CommunityModal';
import EditCommunityModal from '../../components/elements/EditCommunityModal';
import UsersModal from '../../components/elements/UsersModal';
import Join from './Join';
import CommunityPage from './Community';
import { Settings, Collection } from '../../components/elements/Icons';
const { getCommunityQuery } = require('../../graphql/getCommunity.graphql');
enum TabsEnum {
  // Overview = 'Overview',
  Collections = 'Collections',
  Discussion = 'Discussion'
}
import { Route, Switch } from 'react-router-dom';
import Thread from '../thread';

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

  render() {
    let collections;
    let community;
    console.log(this.props.match.params.community);
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
            {community.followed ? (
              <Header>
                <Actions>
                  <Create onClick={this.props.handleNewCollection}>
                    <WrapperAction>
                      <span>
                        <Collection
                          width={40}
                          height={40}
                          strokeWidth={1}
                          color={'#f98012'}
                        />
                      </span>
                      <Trans>Create a collection</Trans>
                    </WrapperAction>
                  </Create>
                </Actions>
              </Header>
            ) : (
              <Footer>
                <Trans>Join the community to create a collection</Trans>
              </Footer>
            )}

            <CollectionList>
              {this.props.data.community.collections.edges.map((e, i) => (
                <CollectionCard
                  communityId={this.props.data.community.localId}
                  key={i}
                  collection={e.node}
                />
              ))}
            </CollectionList>
          </Wrapper>
        );
      } else {
        collections = (
          <OverviewCollection>
            <P>
              <Trans>This community has no collections.</Trans>
            </P>
            {community.followed ? (
              <Header style={{ marginBottom: '8px' }}>
                <Actions>
                  <Create onClick={this.props.handleNewCollection}>
                    <WrapperAction>
                      <span>
                        <Collection
                          width={40}
                          height={40}
                          strokeWidth={1}
                          color={'#282828'}
                        />
                      </span>
                      <Trans>Create a collection</Trans>
                    </WrapperAction>
                  </Create>
                </Actions>
              </Header>
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
      if (this.props.data.loading) {
        return <Loader />;
      } else {
        // TODO better handling of no community
        return (
          <span>
            <Trans>Could not load the community.</Trans>
          </span>
        );
      }
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

                  <HeroInfo>
                    <H2>{community.name}</H2>
                    <P>{community.summary}</P>
                    <HeroActions>
                      <MembersTot onClick={() => this.props.showUsers(true)}>
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
                    </HeroActions>
                  </HeroInfo>
                </Hero>
              </HeroCont>

              <Switch>
                <Route
                  path={`/communities/${community.localId}/thread/:id`}
                  component={Thread}
                />
                <Route
                  path={this.props.match.url}
                  exact
                  render={props => (
                    <CommunityPage
                      {...props}
                      collections={collections}
                      community={community}
                      fetchMore={this.props.data.fetchMore}
                      type={'community'}
                    />
                  )}
                />
              </Switch>
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

const WrapperAction = styled.div`
  text-align: center;
  flex: 1;
`;
export const Actions = styled.div`
  ${clearFix()};
  display: flex;
`;

export const Create = styled.div`
  display: flex;
  cursor: pointer;
  padding: 8px 0;
  position: relative;
  background: ${props => props.theme.styles.colour.newcommunityBg};
  border-radius: 6px;
  margin-bottom: 8px;
  flex: 1;
  margin: 8px;
  height: 120px;
  margin-top: 16px;
  display: flex;
  align-items: center;
  color: #f98012;
  border: 2px dashed #f98012;
  & span {
    display: inherit;
    margin-bottom: 8px;
    margin: 0 16px;
  }
  ${media.lessThan('medium')`display: block;`} & a {
    display: flex;
    color: inherit;
    text-decoration: none;
    width: 100%;
  }
  &:hover {
    background: ${props => props.theme.styles.colour.newcommunityBgHover};
  }
`;

const Header = styled.div`
  ${clearFix()};
`;
const HeroActions = styled.div`
  position: relative;
`;

const HeroCont = styled.div`
  margin-bottom: 16px;
  border-radius: 6px;
  box-sizing: border-box;
  background: ${props => props.theme.styles.colour.communityBg};
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
  cursor: pointer;
  display: inline-block;
  cursor: pointer;
  ${clearFix()} & span {
    margin-right: 8px;
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
  position: absolute;
  right: 40px;
  top: 0;
  &:hover {
    svg {
      color: ${props => props.theme.styles.colour.primary};
    }
  }
  & svg {
    margin-top: 8px;
    text-align: center;
  }
`;

const Footer = styled.div`
  height: 30px;
  line-height: 30px;
  font-weight: 600;
  text-align: center;
  background: #ffefd9;
  font-size: 13px;
  border-bottom: 1px solid ${props => props.theme.styles.colour.divider};
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
  height: 250px;
  background-size: cover;
  background-repeat: no-repeat;
  background-color: #e6e6e6;
  position: relative;
  margin: 0 auto;
  background-position: center center;
`;

const HeroInfo = styled.div`
  padding: 16px;
  & h2 {
    margin: 0;
    font-size: 24px !important;
    line-height: 40px !important;
    margin-bottom: 0px;
    color: ${props => props.theme.styles.colour.communityTitle};
  }
  & p {
    margin-top: 8px;
    color: ${props => props.theme.styles.colour.communityNote};
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
      context: Number(props.match.params.community)
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
