import * as React from 'react';

import styled from '../../../themes/styled';

const Bounce = styled.div<any>`
  background-color: ${props => props.theme.styles.colour.primary};
`;

export default () => {
  return (
    <div className="spinner">
      <Bounce className="bounce1" />
      <Bounce className="bounce2" />
      <Bounce className="bounce3" />
    </div>
  );
};
