import * as React from 'react';
import { MD } from '@zendeskgarden/react-typography';

import { HeadingProps } from '../H1/H1';

const H5 = ({ children, tag = 'h5', ...props }: HeadingProps) => {
  return (
    <MD tag={tag} {...props}>
      {children}
    </MD>
  );
};

export default H5;
