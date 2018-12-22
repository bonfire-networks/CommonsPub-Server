import * as React from 'react';
import { LG } from '@zendeskgarden/react-typography';

import { HeadingProps } from '../H1/H1';

/**
 * H4 component.
 * @param children {JSX.Element} children of the header
 * @param [tag] {String} the element tag name
 * @param props {Object} props of the tag
 * @constructor
 */
const H4 = ({ children, tag = 'h4', ...props }: HeadingProps) => {
  return (
    <LG tag={tag} {...props}>
      {children}
    </LG>
  );
};

export default H4;
