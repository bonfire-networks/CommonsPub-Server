import * as React from 'react';
import { Avatar } from '@zendeskgarden/react-avatars';

type AvatarProps = {
  size: 'small' | 'large';
  marked?: boolean;
  className?: string;
  children?: any;
};

export default ({
  children,
  marked = false,
  className = '',
  ...props
}: AvatarProps) => {
  if (marked) {
    className += ' marked';
  }
  return (
    <Avatar className={className} {...props}>
      {children}
    </Avatar>
  );
};
