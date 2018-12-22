import * as React from 'react';
import { XXL } from '@zendeskgarden/react-typography';

import { HeadingProps } from '../H1/H1';

/**
 * H2 component.
 * @param children {JSX.Element} children of the header
 * @param [tag] {String} the element tag name
 * @param props {Object} props of the tag
 * @constructor
 */
const H2 = ({ children, tag = 'h2', ...props }: HeadingProps) => {
  return (
    <XXL tag={tag} {...props}>
      {children}
    </XXL>
  );
};

export default H2;
