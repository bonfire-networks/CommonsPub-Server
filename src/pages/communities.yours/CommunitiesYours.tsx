import * as React from 'react';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';

import H1 from '../../components/typography/H1/H1';
import P from '../../components/typography/P/P';
import CommunityCard from '../../components/elements/Card/Card';
import styled from 'styled-components';
import Logo from '../../components/brand/Logo/Logo';

const cardBg = require('../../static/img/styleguide/the-red-group-community.png');

const PageTitle = styled(H1)`
  font-size: 30px !important;
  margin-block-start: 0;
  margin-block-end: 0;
`;

const Main = styled.div`
  margin: 10px 15px;
  max-width: 1000px;
  overflow: hidden;
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

export default function CommunitiesFeatured() {
  return (
    <Main>
      <Grid>
        <Row>
          <Col sm={12}>
            <Logo />
            <PageTitle>Your Communities</PageTitle>
          </Col>
        </Row>
        <Row>
          <Col>
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
          <Col size={12} style={{ display: 'flex' }}>
            {cards.map(card => {
              return <CommunityCard key={card.id} {...card} />;
            })}
          </Col>
        </Row>
        <Row>
          <Col size={12} style={{ display: 'flex' }}>
            {cards.map(card => {
              return <CommunityCard key={card.id} {...card} />;
            })}
          </Col>
        </Row>
        <Row>
          <Col size={12} style={{ display: 'flex' }}>
            {cards.map(card => {
              return <CommunityCard key={card.id} {...card} />;
            })}
          </Col>
        </Row>
      </Grid>
    </Main>
  );
}
