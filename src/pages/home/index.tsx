import React from 'react';
import { compose } from 'recompose';
// const { getUserQuery } = require('../../graphql/getUser.client.graphql');
// import styled from '../../themes/styled';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import { WrapperCont, Wrapper } from '../communities.all/CommunitiesAll';
import Main from '../../components/chrome/Main/Main';
import { Trans } from '@lingui/macro';
import { SuperTab, SuperTabList } from '../../components/elements/SuperTab';
import { Tabs, TabPanel } from 'react-tabs';
import { User } from '../../components/elements/Icons';
const getMeInboxQuery = require('../../graphql/getMeInbox.graphql');
import Loader from '../../components/elements/Loader/Loader';
import TimelineItem from '../../components/elements/TimelineItem';
import LoadMoreTimeline from '../../components/elements/Loadmore/timeline';

interface Data extends GraphqlQueryControls {
  me: {
    user: {
      name: string;
      icon: string;
      summary: string;
      id: string;
      localId: string;
      inbox: any;
    };
  };
}

interface Props {
  data: Data;
}

const Home: React.SFC<Props> = props => {
  return (
    <Main>
      <WrapperCont>
        <Wrapper>
          <Tabs>
            <SuperTabList>
              <SuperTab>
                <span>
                  <User
                    width={20}
                    height={20}
                    strokeWidth={2}
                    color={'#a0a2a5'}
                  />
                </span>
                <h5>
                  <Trans>Your feed</Trans>
                </h5>
              </SuperTab>
            </SuperTabList>
            <TabPanel>
              {props.data.error ? (
                <span>
                  <Trans>Error loading user</Trans>
                </span>
              ) : props.data.loading ? (
                <Loader />
              ) : (
                <div>
                  {props.data.me.user.inbox.edges.map((t, i) => (
                    <TimelineItem node={t.node} user={t.node.user} key={i} />
                  ))}
                  <div style={{ padding: '8px' }}>
                    <LoadMoreTimeline
                      fetchMore={props.data.fetchMore}
                      community={props.data.me.user}
                    />
                  </div>
                </div>
              )}
            </TabPanel>
          </Tabs>
        </Wrapper>
      </WrapperCont>
    </Main>
  );
};

const withGetInbox = graphql<
  {},
  {
    data: {
      me: any;
    };
  }
>(getMeInboxQuery, {
  options: (props: Props) => ({
    variables: {
      limit: 15
    }
  })
}) as OperationOption<{}, {}>;

export default compose(withGetInbox)(Home);
