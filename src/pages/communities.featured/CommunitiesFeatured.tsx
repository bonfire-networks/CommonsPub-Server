import * as React from 'react';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';

const { H1 } = require('../../components/typography/H1/H1');
const { Card } = require('../../components/elements/Card/Card');

export const CommunitiesFeatured = () => (
  <React.Fragment>
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
  </React.Fragment>
);
