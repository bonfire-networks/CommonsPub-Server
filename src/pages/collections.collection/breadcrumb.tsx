import * as React from 'react';
import { SFC } from 'react';
import { Row, Col } from '@zendeskgarden/react-grid';
import Link from '../../components/elements/Link/Link';

interface Props {
  community: {
    id: string;
    name: string;
  };
  collectionName: string;
}

const Breadcrumb: SFC<Props> = ({ community, collectionName }) => (
  <>
    <Row>
      <Col size={6}>
        <Link to="/communities">Communities</Link>
        {' > '}
        <Link to={`/communities/${community.id}`}>{community.name}</Link>
        {' > '}
        <span>{collectionName}</span>
      </Col>
    </Row>
  </>
);

export default Breadcrumb;
