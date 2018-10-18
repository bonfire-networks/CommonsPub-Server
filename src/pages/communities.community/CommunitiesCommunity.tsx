import * as React from 'react';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';

import Link from '../../components/elements/Link/Link';
import Main from '../../components/chrome/Main/Main';
import Logo from '../../components/brand/Logo/Logo';
import { Tabs, TabPanel } from '../../components/chrome/Tabs/Tabs';
import {
  CommunityCard,
  CollectionCard
} from '../../components/elements/Card/Card';
import {
  DUMMY_COMMUNITIES,
  DUMMY_COLLECTIONS
} from '../../__DEV__/dummy-cards';
import P from '../../components/typography/P/P';

const card = DUMMY_COMMUNITIES[0];

enum TabsEnum {
  Collections = 'Collections',
  Discussion = 'Discussion'
}

export default class CommunitiesFeatured extends React.Component {
  state = {
    tab: TabsEnum.Collections
  };

  render() {
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
                <span>{card.title}</span>
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
                  <CommunityCard large link={false} key={card.id} {...card} />
                  <div>
                    <h3>{card.title}</h3>
                    <P>{card.description}</P>
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
                    <div style={{ display: 'flex' }}>
                      {DUMMY_COLLECTIONS.map(card => {
                        return <CollectionCard key={card.id} {...card} />;
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
