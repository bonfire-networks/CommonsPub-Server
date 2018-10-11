import * as React from 'react';
import { XXXL } from '@zendeskgarden/react-typography';

export interface HeadingProps {
  children?: any;
  tag?: string;
  style?: object;
}

const H1 = ({ children, tag = 'h1', ...props }: HeadingProps) => {
  return (
    <XXXL tag={tag} {...props}>
      {children}
    </XXXL>
  );
};

export default H1;
