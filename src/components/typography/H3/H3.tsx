import * as React from 'react';
import { XL } from '@zendeskgarden/react-typography';

import { HeadingProps } from '../H1/H1';

/**
 * H3 component.
 * @param children {JSX.Element} children of the header
 * @param [tag] {String} the element tag name
 * @param props {Object} props of the tag
 * @constructor
 */
const H3 = ({ children, tag = 'h3', ...props }: HeadingProps) => {
  return (
    <XL tag={tag} {...props}>
      {children}
    </XL>
  );
};

export default H3;
