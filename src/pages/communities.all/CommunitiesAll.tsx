import * as React from 'react';
import { compose } from 'recompose';
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
      </Main>
    );
  }
}

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
    variables: {
      limit: 15
    }
  })
}) as OperationOption<{}, {}>;

export default compose(withGetCommunities)(CommunitiesYours);
