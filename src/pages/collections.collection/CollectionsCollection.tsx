import * as React from 'react';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';

import styled from '../../themes/styled';
import Link from '../../components/elements/Link/Link';
import Logo from '../../components/brand/Logo/Logo';
import slugify from '../../util/slugify';
import Main from '../../components/chrome/Main/Main';
import P from '../../components/typography/P/P';
import Avatar from '../../components/elements/Avatar/Avatar';
import { Tabs, TabPanel } from '../../components/chrome/Tabs/Tabs';
import {
  CollectionCard,
  ResourceCard
} from '../../components/elements/Card/Card';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import Collection from '../../types/Collection';
import compose from 'recompose/compose';
import { RouteComponentProps } from 'react-router';
import Loader from '../../components/elements/Loader/Loader';

const { getCommunityQuery } = require('../../graphql/getCommunity.graphql');

const Contributors = styled.div`
  margin: 20px 0;
`;

enum TabsEnum {
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
}

class CommunitiesFeatured extends React.Component<Props> {
  state = {
    tab: TabsEnum.Resources
  };

  render() {
    let collection;
    let resources = [];

    if (this.props.data.error) {
      console.error(this.props.data.error);
      collection = null;
    } else if (this.props.data.loading) {
      return <Loader />;
    } else {
      collection = this.props.data.collection;
    }

    if (!collection) {
      // TODO better handling of no collection
      return <span>Could not load collection.</span>;
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
                Collection by{' '}
                <Link
                  to={`/communities/${slugify(collection.community.title)}`}
                >
                  {collection.community.title}
                </Link>
                {' > '}
                <span>{collection.title}</span>
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
                  <CollectionCard large entity={collection} />
                  <div>
                    {/*TODO use correct header typography component*/}
                    <h3>{collection.title}</h3>
                    <P>{collection.description}</P>
                  </div>
                </div>
              </Col>
            </Row>
            <Row>
              <Col size={6}>
                <h3>Contributors</h3>
                <Contributors>
                  {collection.contributors.map((c, i) => {
                    return (
                      <Avatar key={i} marked={c.id === collection.creatorId}>
                        <img src={c.avatarImage} alt={c.name} />
                      </Avatar>
                    );
                  })}
                </Contributors>
              </Col>
            </Row>
            <Row>
              <Col size={12}>
                <Tabs
                  selectedKey={this.state.tab}
                  onChange={tab => this.setState({ tab })}
                >
                  <TabPanel label={TabsEnum.Resources} key={TabsEnum.Resources}>
                    <div style={{ display: 'flex', flexWrap: 'wrap' }}>
                      {resources.map(resource => {
                        return (
                          <ResourceCard key={collection.id} entity={resource} />
                        );
                      })}
                    </div>
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

const withGetCommunity = graphql<
  {},
  {
    data: {
      collections: Collection[];
    };
  }
>(getCommunityQuery, {
  options: (props: Props) => ({
    variables: {
      context: parseInt(props.match.params.community)
    }
  })
}) as OperationOption<{}, {}>;

export default compose(withGetCommunity)(CommunitiesFeatured);
