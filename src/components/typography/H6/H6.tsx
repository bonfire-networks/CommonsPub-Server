import * as React from 'react';
import { SM } from '@zendeskgarden/react-typography';

import { HeadingProps } from '../H1/H1';

/**
 * H6 component.
 * @param children {JSX.Element} children of the header
 * @param [tag] {String} the element tag name
 * @param props {Object} props of the tag
 * @constructor
 */
const H6 = ({ children, tag = 'h6', ...props }: HeadingProps) => {
  return (
    <SM tag={tag} {...props}>
      {children}
    </SM>
  );
};

export default H6;
