import * as React from 'react';
import { MD } from '@zendeskgarden/react-typography';

import { HeadingProps } from '../H1/H1';

/**
 * H5 component.
 * @param children {JSX.Element} children of the header
 * @param [tag] {String} the element tag name
 * @param props {Object} props of the tag
 * @constructor
 */
const H5 = ({ children, tag = 'h5', ...props }: HeadingProps) => {
  return (
    <MD tag={tag} {...props}>
      {children}
    </MD>
  );
};

export default H5;
