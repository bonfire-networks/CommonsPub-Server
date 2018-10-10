import * as React from 'react';
import { XL } from '@zendeskgarden/react-typography';

import { HeadingProps } from '../H1/H1';

const H3 = ({ children, tag = 'h3', ...props }: HeadingProps) => {
  return (
    <XL tag={tag} {...props}>
      {children}
    </XL>
  );
};

export default H3;
