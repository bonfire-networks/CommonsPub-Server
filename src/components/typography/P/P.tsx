import * as React from 'react';

export default function({ children, ...props }) {
  return <p {...props}>{children}</p>;
}
