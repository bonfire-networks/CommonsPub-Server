import * as React from 'react';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';

import H1 from '../../components/typography/H1/H1';
import P from '../../components/typography/P/P';
import styled from 'styled-components';
import Logo from '../../components/brand/Logo/Logo';
import Main from '../../components/chrome/Main/Main';
import { CommunityCard } from '../../components/elements/Card/Card';

const cardBg = require('../../static/img/styleguide/the-red-group-community.png');

const PageTitle = styled(H1)`
  font-size: 30px !important;
  margin-block-start: 0;
  margin-block-end: 0;
`;

const rand = () => Math.max(1, Math.floor(Math.random() * 20));

const cards = [
  {
    id: 0,
    title: 'The Red Group',
    backgroundImage: cardBg,
    contentCounts: {
      Members: rand(),
      Collections: rand()
    },
    joined: true,
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 1,
    title: 'The Red Group',
    backgroundImage: cardBg,
    contentCounts: {
      Members: rand(),
      Collections: rand()
    },
    joined: true,
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 2,
    title: 'The Red Group',
    backgroundImage: cardBg,
    contentCounts: {
      Members: rand(),
      Collections: rand()
    },
    joined: true,
    onButtonClick: () => alert('card btn clicked')
  }
];

export default function CommunitiesYours() {
  return (
    <Main>
      <Grid>
        <Row>
          <Col sm={6}>
            <Logo />
            <PageTitle>Your Communities</PageTitle>
          </Col>
        </Row>
        <Row>
          <Col size={6}>
            <P>
              Lorem ipsum dolor sit amet, consectetur adipiscing elit.
              Vestibulum ornare pretium tellus ut laoreet. Donec nec pulvinar
              diam. Fusce sed est sed sem condimentum porttitor eget non turpis.
              Sed dictum pulvinar dui, iaculis ultrices orci scelerisque non.
              Integer a dignissim arcu. Nunc eu mi orci. Fusce ante sapien,
              elementum in gravida ut, porta ut erat. Suspendisse potenti.
            </P>
          </Col>
        </Row>
        <Row>
          <Col size={10} style={{ display: 'flex', flexWrap: 'wrap' }}>
            {cards.map(card => {
              return <CommunityCard key={card.id} {...card} />;
            })}
            {cards.map(card => {
              return <CommunityCard key={card.id} {...card} />;
            })}
            {cards.map(card => {
              return <CommunityCard key={card.id} {...card} />;
            })}
          </Col>
        </Row>
      </Grid>
    </Main>
  );
}
