import * as React from 'react';
import compose from 'recompose/compose';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import { Trans } from '@lingui/macro';
import { WrapperCont, Wrapper } from '../communities.all/CommunitiesAll';
import Main from '../../components/chrome/Main/Main';
import CollectionType from '../../types/Collection';
import Loader from '../../components/elements/Loader/Loader';
import CollectionCard from '../../components/elements/Collection/Collection';
import CollectionsLoadMore from '../../components/elements/Loadmore/collections';
import { Collection, Eye } from '../../components/elements/Icons';
import { SuperTab, SuperTabList } from '../../components/elements/SuperTab';
import { Tabs, TabPanel } from 'react-tabs';
import styled from '../../themes/styled';
import CollectionsFollowed from '../collections.followed';
import { Helmet } from 'react-helmet';

const { getCollectionsQuery } = require('../../graphql/getCollections.graphql');

interface Data extends GraphqlQueryControls {
  collections: {
    nodes: CollectionType[];
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
                    <Collection
                      width={20}
                      height={20}
                      strokeWidth={2}
                      color={'#a0a2a5'}
                    />
                  </span>
                  <h5>
                    <Trans>All collections</Trans>
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
                    <Trans>Followed collections</Trans>
                  </h5>
                </SuperTab>
              </SuperTabList>
              <TabPanel>
                <div>
                  {this.props.data.error ? (
                    <span>
                      <Trans>Error loading collections</Trans>
                    </span>
                  ) : this.props.data.loading ? (
                    <Loader />
                  ) : (
                    <>
                      <Helmet>
                        <title>MoodleNet > All collections</title>
                      </Helmet>
                      <List>
                        {this.props.data.collections.nodes.map((coll, i) => (
                          <CollectionCard key={i} collection={coll} />
                        ))}
                      </List>
                      <CollectionsLoadMore
                        fetchMore={this.props.data.fetchMore}
                        collections={this.props.data.collections}
                      />
                    </>
                  )}
                </div>
              </TabPanel>
              <TabPanel>
                <CollectionsFollowed />
              </TabPanel>
            </Tabs>
          </Wrapper>
        </WrapperCont>
      </Main>
    );
  }
}

const List = styled.div`
  display: grid;
  grid-template-columns: 1fr;
  padding-top: 0;
`;

const withGetCommunities = graphql<
  {},
  {
    data: {
      communities: CollectionType[];
    };
  }
>(getCollectionsQuery, {
  options: (props: Props) => ({
    variables: {
      limit: 15
    }
  })
}) as OperationOption<{}, {}>;

export default compose(withGetCommunities)(CommunitiesYours);
