import * as React from 'react';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';

import Card from '../../components/elements/Card/Card';
import H1 from '../../components/typography/H1/H1';

export default function CommunitiesFeatured() {
  return (
    <>
      <Grid>
        <Row>
          <Col sm={12}>
            <H1>Featured Communities</H1>
          </Col>
        </Row>
      </Grid>
      <Grid>
        <Row>
          <Col lg={4}>
            <Card title="A community" />
          </Col>
          <Col lg={4}>
            <Card title="Another community" />
          </Col>
          <Col lg={4}>
            <Card title="Another another community" />
          </Col>
          <Col lg={4}>
            <Card title="Another again community" />
          </Col>
          <Col lg={4}>
            <Card title="Another again community" />
          </Col>
          <Col lg={4}>
            <Card title="The best community" />
          </Col>
        </Row>
      </Grid>
    </>
  );
}
