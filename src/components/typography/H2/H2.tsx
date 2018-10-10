import * as React from 'react';
import { XXL } from '@zendeskgarden/react-typography';

import { HeadingProps } from '../H1/H1';

const H2 = ({ children, tag = 'h2', ...props }: HeadingProps) => {
  return (
    <XXL tag={tag} {...props}>
      {children}
    </XXL>
  );
};

export default H2;
