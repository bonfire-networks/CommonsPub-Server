import * as React from 'react';
import { SFC } from 'react';

import { Trans } from '@lingui/macro';

import Link from '../../components/elements/Link/Link';
import { Main } from '../communities.community/breadcrumb';
import { Helmet } from 'react-helmet';

interface Props {
  community: {
    id: string;
    name: string;
  };
  collectionName: string;
}

const Breadcrumb: SFC<Props> = ({ community, collectionName }) => (
  <Main>
    <Helmet>
      <title>
        MoodleNet > Community > {community.name} > Collection > {collectionName}
      </title>
    </Helmet>
    <Link to="/communities">
      <Trans>Communities</Trans>
    </Link>
    {' > '}
    <Link to={`/communities/${community.id}`}>{community.name}</Link>
    {' > '}
    <span>{collectionName}</span>
  </Main>
);

export default Breadcrumb;
