import * as React from 'react';
import { compose, withState, withHandlers } from 'recompose';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import styled from '../../themes/styled';

import { Trans } from '@lingui/macro';

// import H4 from '../../components/typography/H4/H4';
import Main from '../../components/chrome/Main/Main';
import CommunityType from '../../types/Community';
import Loader from '../../components/elements/Loader/Loader';
import CommunityCard from '../../components/elements/Community/Community';
import media from 'styled-media-query';
import CommunitiesLoadMore from '../../components/elements/Loadmore/community';
import { Community, Eye } from '../../components/elements/Icons';
import { SuperTab, SuperTabList } from '../../components/elements/SuperTab';
import { Tabs, TabPanel } from 'react-tabs';
import CommunitiesJoined from '../communities.joined';
import { Helmet } from 'react-helmet';
import NewCommunityModal from '../../components/elements/CreateCommunityModal';
const { getCommunitiesQuery } = require('../../graphql/getCommunities.graphql');

interface Data extends GraphqlQueryControls {
  communities: {
    nodes: CommunityType[];
    pageInfo: {
      startCursor: number;
      endCursor: number;
    };
  };
}

interface Props {
  data: Data;
  handleNewCommunity(boolean): boolean;
  isOpenCommunity: boolean;
}

class CommunitiesYours extends React.Component<Props> {
  render() {
    return (
      <Main>
        <WrapperCont>
          <Wrapper>
            <Tabs>
              <SuperTabList>
                <SuperTab>
                  <span>
                    <Community
                      width={20}
                      height={20}
                      strokeWidth={2}
                      color={'#a0a2a5'}
                    />
                  </span>
                  <h5>
                    <Trans>All communities</Trans>
                  </h5>
                </SuperTab>
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
                    <Trans>Joined communities</Trans>
                  </h5>
                </SuperTab>
              </SuperTabList>
              <TabPanel>
                {this.props.data.error ? (
                  <span>
                    <Trans>Error loading communities</Trans>
                  </span>
                ) : this.props.data.loading ? (
                  <Loader />
                ) : (
                  <>
                    <Helmet>
                      <title>MoodleNet > All communities</title>
                    </Helmet>
                    <List>
                      <AddNewCommunity onClick={this.props.handleNewCommunity}>
                        <Action>
                          <span>
                            <Community
                              width={30}
                              height={30}
                              color={'#f98011'}
                              strokeWidth={1}
                            />
                          </span>
                          <Title>
                            <Trans>Create a new community</Trans>
                          </Title>
                        </Action>
                      </AddNewCommunity>
                      {this.props.data.communities.nodes.map((community, i) => {
                        return (
                          <CommunityCard
                            key={i}
                            summary={community.summary}
                            title={community.name}
                            icon={community.icon || ''}
                            id={community.localId}
                            followed={community.followed}
                            followersCount={community.members.totalCount}
                            collectionsCount={community.collections.totalCount}
                            externalId={community.id}
                            threadsCount={community.threads.totalCount}
                          />
                        );
                      })}
                    </List>
                    <div style={{ padding: '8px' }}>
                      <CommunitiesLoadMore
                        fetchMore={this.props.data.fetchMore}
                        communities={this.props.data.communities}
                      />
                    </div>
                  </>
                )}
              </TabPanel>
              <TabPanel>
                <CommunitiesJoined />
              </TabPanel>
            </Tabs>
          </Wrapper>
        </WrapperCont>
        <NewCommunityModal
          toggleModal={this.props.handleNewCommunity}
          modalIsOpen={this.props.isOpenCommunity}
        />
      </Main>
    );
  }
}
const Action = styled.div`
  text-align: center;
  margin: 0 auto;
`;
const Title = styled.h5``;

const AddNewCommunity = styled.div`
  padding: 8px;
  position: relative;
  max-height: 560px;
  background: ${props => props.theme.styles.colour.newcommunityBg};
  border-radius: 6px;
  overflow: hidden;
  z-index: 9;
  border: 1px dashed #f98011;
  cursor: pointer;
  display: flex;
  align-items: center;
  &:hover {
    background: ${props => props.theme.styles.colour.newcommunityBgHover};
  }
  & h5 {
    margin: 0;
    font-size: 14px !important;
    line-height: 24px !important;
    word-break: break-word;
    font-weight: 500;
    color: #f98011;
  }
  & a {
    color: inherit;
    text-decoration: none;
    &:hover {
      text-decoration: underline;
    }
  }
`;

export const WrapperCont = styled.div`
  max-width: 1040px;
  margin: 0 auto;
  width: 100%;
  height: 100%;
`;

export const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  flex: 1;
  margin-bottom: 24px;
  background: ${props => props.theme.styles.colour.secondaryBg};
  border-radius: 6px;
  margin-top: 16px;
  & ul {
    display: block !important;

    & li {
      display: inline-block;

      & h5 {
        font-size: 13px;
        font-weight: 500;
        color: ${props => props.theme.styles.colour.base3};
      }
    }
  }
  & h4 {
    margin: 0;
    font-weight: 400 !important;
    font-size: 14px !important;
    color: #151b26;
    line-height: 40px;
  }
`;
export const List = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  grid-column-gap: 16px;
  grid-row-gap: 16px;
  padding-top: 0;
  padding: 16px;
  ${media.lessThan('medium')`
  grid-template-columns: 1fr;
  `};
`;

const withGetCommunities = graphql<
  {},
  {
    data: {
      communities: CommunityType[];
    };
  }
>(getCommunitiesQuery, {
  options: (props: Props) => ({
    fetchPolicy: 'cache-first',
    variables: {
      limit: 15
    }
  })
}) as OperationOption<{}, {}>;

export default compose(
  withGetCommunities,
  withState('isOpenCommunity', 'onOpenCommunity', false),
  withHandlers({
    handleNewCommunity: props => () =>
      props.onOpenCommunity(!props.isOpenCommunity)
  })
)(CommunitiesYours);
