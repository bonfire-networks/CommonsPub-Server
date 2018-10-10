import * as React from 'react';
import { LG } from '@zendeskgarden/react-typography';

import { HeadingProps } from '../H1/H1';

const H4 = ({ children, tag = 'h4', ...props }: HeadingProps) => {
  return (
    <LG tag={tag} {...props}>
      {children}
    </LG>
  );
};

export default H4;
