import * as React from 'react';

import styled from '../../../themes/styled';

const Bounce = styled.div<any>`
  background-color: ${props => props.theme.styles.colour.primary};
`;

/**
 * Loader spinner component.
 * @param props {Object} props of the loader
 * @constructor
 */
function Loader({ ...props }) {
  return (
    <div className="spinner" {...props}>
      <Bounce className="bounce1" />
      <Bounce className="bounce2" />
      <Bounce className="bounce3" />
    </div>
  );
}

export default Loader;
