import * as React from 'react';

import { Trans } from '@lingui/macro';

import styled from '../../themes/styled';
import H3 from '../../components/typography/H3/H3';

const NotFound = styled.div`
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
`;

export default () => {
  return (
    <NotFound>
      <H3>
        <Trans>Page not found</Trans>
      </H3>
    </NotFound>
  );
};
