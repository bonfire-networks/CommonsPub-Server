import * as React from 'react';
import { SM } from '@zendeskgarden/react-typography';

import { HeadingProps } from '../H1/H1';

const H6 = ({ children, tag = 'h6', ...props }: HeadingProps) => {
  return (
    <SM tag={tag} {...props}>
      {children}
    </SM>
  );
};

export default H6;
