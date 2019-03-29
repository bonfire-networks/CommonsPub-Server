import * as React from 'react';
import { SFC } from 'react';

import { Trans } from '@lingui/macro';

import Link from '../../components/elements/Link/Link';
import styled from '../../themes/styled';

interface Props {
  community: {
    id: string;
    name: string;
  };
  collectionName: string;
}

const Breadcrumb: SFC<Props> = ({ community, collectionName }) => (
  <Main>
    <Link to="/communities">
      <Trans>Communities</Trans>
    </Link>
    {' > '}
    <Link to={`/communities/${community.id}`}>{community.name}</Link>
    {' > '}
    <span>{collectionName}</span>
  </Main>
);

const Main = styled.div`
  font-size: 12px;
  font-weight: 700;
  text-decoration: none;
  text-transform: uppercase;
  line-height: 30px;
  border-radius: 6px;
  background: #fff;
  padding: 0 8px;
  & a {
    font-size: 12px;
    font-weight: 700;
    text-decoration: none;
    text-transform: uppercase;
    margin-right: 6px;
  }
  & span {
    font-size: 12px;
    font-weight: 500;
    text-decoration: none;
    text-transform: uppercase;
    margin-left: 6px;
    color: ${props => props.theme.styles.colour.base2};
  }
`;

export default Breadcrumb;
