import * as React from 'react';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';

import H1 from '../../components/typography/H1/H1';

import styled from '../../themes/styled';
import P from '../../components/typography/P/P';
import Main from '../../components/chrome/Main/Main';
import Logo from '../../components/brand/Logo/Logo';
import { CommunityCard } from '../../components/elements/Card/Card';
import { DUMMY_COMMUNITIES } from '../../__DEV__/dummy-cards';

const PageTitle = styled(H1)`
  font-size: 30px !important;
  margin-block-start: 0;
  margin-block-end: 0;
`;

export default function CommunitiesFeatured() {
  return (
    <>
      <Main>
        <Grid>
          <Row>
            <Col size={6}>
              <Logo />
              <PageTitle>Featured Communities</PageTitle>
            </Col>
          </Row>
          <Row>
            <Col size={6}>
              <P>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit.
                Vestibulum ornare pretium tellus ut laoreet. Donec nec pulvinar
                diam. Fusce sed est sed sem condimentum porttitor eget non
                turpis. Sed dictum pulvinar dui, iaculis ultrices orci
                scelerisque non. Integer a dignissim arcu. Nunc eu mi orci.
                Fusce ante sapien, elementum in gravida ut, porta ut erat.
                Suspendisse potenti.
              </P>
            </Col>
          </Row>
          <Row>
            <Col size={10} style={{ display: 'flex', flexWrap: 'wrap' }}>
              {DUMMY_COMMUNITIES.map(card => {
                return <CommunityCard key={card.id} {...card} />;
              })}
              {DUMMY_COMMUNITIES.map(card => {
                return <CommunityCard key={card.id} {...card} />;
              })}
              {DUMMY_COMMUNITIES.map(card => {
                return <CommunityCard key={card.id} {...card} />;
              })}
            </Col>
          </Row>
        </Grid>
      </Main>
    </>
  );
}
