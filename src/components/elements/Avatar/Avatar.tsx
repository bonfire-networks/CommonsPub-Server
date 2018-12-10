import * as React from 'react';
import { Avatar } from '@zendeskgarden/react-avatars';

type AvatarProps = {
  size?: 'small' | 'large';
  marked?: boolean;
  className?: string;
  children?: any;
};

/**
 * Avatar component.
 * @param children {JSX.Element} children of Avatar
 * @param size {"small"|"large"} size of avatar
 * @param marked {Boolean} whether blue dot should appear on avatar
 * @param className {String} additional class names of avatar
 * @param props {Object} avatar props
 */
export default ({
  children,
  size = 'small',
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
