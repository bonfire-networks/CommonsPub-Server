import * as React from 'react';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';
import { Redirect } from 'react-router';
import { Tabs, TabPanel } from '../../components/chrome/Tabs/Tabs';

import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
// import {
//   CollectionCard,
//   CommunityCard,
//   ResourceCard
// } from '../../components/elements/Card/Card';
import Logo from '../../components/brand/Logo/Logo';
import P from '../../components/typography/P/P';

const CardContainer = styled.div`
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
`;

const yourLikes = (
  <Row>
    <Col size={10}>
      <h4>Your Likes</h4>
      <CardContainer>
        {/*<ResourceCard {...DUMMY_RESOURCES[0]} />*/}
      </CardContainer>
    </Col>
  </Row>
);

const communities = (
  <Row>
    <Col size={10}>
      <h4>Communities</h4>
      <CardContainer>
        {/*{DUMMY_COMMUNITIES.slice(0, 2).map(community => {*/}
        {/*return <CommunityCard key={community.id} {...community} />;*/}
        {/*})}*/}
      </CardContainer>
    </Col>
  </Row>
);

const collections = (
  <Row>
    <Col size={10}>
      <h4>Collections</h4>
      <CardContainer>
        {/*{DUMMY_COLLECTIONS.slice(0, 6).map(collection => {*/}
        {/*return <CollectionCard key={collection.id} {...collection} />;*/}
        {/*})}*/}
      </CardContainer>
    </Col>
  </Row>
);

const resources = (
  <Row>
    <Col size={10}>
      <h4>Resources</h4>
      <CardContainer>
        {/*{DUMMY_RESOURCES.slice(0, 1).map(resource => {*/}
        {/*return <ResourceCard key={resource.id} {...resource} />;*/}
        {/*})}*/}
      </CardContainer>
    </Col>
  </Row>
);

const discussions = (
  <Row>
    <Col size={10}>
      <h4>Discussions</h4>
    </Col>
  </Row>
);

enum TabEnum {
  All = 'All',
  YourLikes = 'Your Likes',
  Communities = 'Communities',
  Collections = 'Collections',
  Resources = 'Resources',
  Discussions = 'Discussions'
}

const items = {
  [TabEnum.YourLikes]: yourLikes,
  [TabEnum.Communities]: communities,
  [TabEnum.Collections]: collections,
  [TabEnum.Resources]: resources,
  [TabEnum.Discussions]: discussions
};

export default class extends React.Component {
  state = {
    tab: TabEnum.All
  };

  render() {
    //TODO support maybe not good enough? e.g. no ie 11 (https://caniuse.com/#feat=urlsearchparams)
    //TODO this is not SSR friendly, accessing window.location!! does react router give query params?
    const urlParams = new URLSearchParams(window.location.search);
    const query = urlParams.get('q');

    if (!query) {
      return <Redirect to="/" />;
    }

    return (
      <Main>
        <Grid>
          <Row>
            <Col size={10}>
              <Logo />
              <P>Search results for {query}</P>
            </Col>
          </Row>
          <Tabs
            selectedKey={this.state.tab}
            onChange={tab => this.setState({ tab })}
          >
            <TabPanel label={TabEnum.All} key={TabEnum.All}>
              <Grid>
                {yourLikes}
                {communities}
                {collections}
                {resources}
                {discussions}
              </Grid>
            </TabPanel>
            {Object.keys(items).map(item => (
              <TabPanel label={item} key={item}>
                <Grid>{items[item]}</Grid>
              </TabPanel>
            ))}
          </Tabs>
        </Grid>
      </Main>
    );
  }
}
