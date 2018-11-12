import * as React from 'react';
import { Avatar } from '@zendeskgarden/react-avatars';

export default ({ children, marked, className = '', ...props }) => {
  if (marked) {
    className += ' marked';
  }
  return (
    <Avatar className={className} {...props}>
      {children}
    </Avatar>
  );
};
