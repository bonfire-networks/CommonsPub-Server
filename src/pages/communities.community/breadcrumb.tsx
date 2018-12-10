import * as React from 'react';
import { SFC } from 'react';
import { Row, Col } from '@zendeskgarden/react-grid';
import Link from '../../components/elements/Link/Link';

interface Props {
  name: string;
}

const Breadcrumb: SFC<Props> = ({ name }) => (
  <>
    <Row>
      <Col size={6}>
        <Link to="/communities">Communities</Link>
        {' > '}
        <span>{name}</span>
      </Col>
    </Row>
  </>
);

export default Breadcrumb;
