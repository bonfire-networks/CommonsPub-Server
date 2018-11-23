import * as React from 'react';
import compose from 'recompose/compose';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';
import { RouteComponentProps } from 'react-router';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';

import Link from '../../components/elements/Link/Link';
import Main from '../../components/chrome/Main/Main';
import Logo from '../../components/brand/Logo/Logo';
import P from '../../components/typography/P/P';
import Community from '../../types/Community';
import Loader from '../../components/elements/Loader/Loader';
import { Tabs, TabPanel } from '../../components/chrome/Tabs/Tabs';
import {
  CommunityCard,
  CollectionCard
} from '../../components/elements/Card/Card';

const { getCommunityQuery } = require('../../graphql/getCommunity.graphql');

enum TabsEnum {
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
}

class CommunitiesFeatured extends React.Component<Props, State> {
  state = {
    tab: TabsEnum.Collections
  };

  render() {
    let collections;
    let community;

    if (this.props.data.error) {
      console.error(this.props.data.error);
      collections = <span>Error loading collections</span>;
    } else if (this.props.data.loading) {
      collections = <Loader />;
    } else if (this.props.data.community.collections) {
      community = this.props.data.community;

      if (this.props.data.community.collections.length) {
        collections = this.props.data.community.collections.map(collection => {
          return <CollectionCard key={community.id} entity={collection} />;
        });
      } else {
        collections = <span>This community has no collections.</span>;
      }
    }

    if (!community) {
      return <Loader />;
    }

    return (
      <>
        <Main>
          <Grid>
            <Row>
              <Col sm={6}>
                <Logo />
              </Col>
            </Row>
            <Row>
              <Col size={6}>
                <Link to="/communities">Communities</Link>
                {' > '}
                <span>{community.name}</span>
              </Col>
            </Row>
            <Row>
              <Col size={6}>
                <div
                  style={{
                    marginTop: '1em',
                    display: 'flex',
                    flexDirection: 'row'
                  }}
                >
                  <CommunityCard
                    large
                    link={false}
                    key={community.id}
                    entity={community}
                  />
                  <div>
                    <h3>{community.name}</h3>
                    <P>{community.summary}</P>
                  </div>
                </div>
              </Col>
            </Row>
            <Row />
            <Row>
              <Col size={12}>
                <Tabs
                  selectedKey={this.state.tab}
                  onChange={tab => this.setState({ tab })}
                >
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
                    discussions
                  </TabPanel>
                </Tabs>
              </Col>
            </Row>
          </Grid>
        </Main>
      </>
    );
  }
}

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

export default compose(withGetCollections)(CommunitiesFeatured);
