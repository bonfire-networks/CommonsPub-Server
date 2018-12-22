import * as React from 'react';
import { XXXL } from '@zendeskgarden/react-typography';

export interface HeadingProps {
  children?: any;
  tag?: string;
  style?: object;
}

/**
 * H1 component.
 * @param children {JSX.Element} children of the header
 * @param [tag] {String} the element tag name
 * @param props {Object} props of the tag
 * @constructor
 */
const H1 = ({ children, tag = 'h1', ...props }: HeadingProps) => {
  return (
    <XXXL tag={tag} {...props}>
      {children}
    </XXXL>
  );
};

export default H1;
