import * as React from 'react';

/**
 * Paragraph component.
 * @param children {JSX.Element} children of the paragraph
 * @param props {Object} props of the paragraph
 * @constructor
 */
export default function({ children, ...props }) {
  return <p {...props}>{children}</p>;
}
