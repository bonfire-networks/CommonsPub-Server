import * as React from 'react';
import { Tag as ZenTag, Close } from '@zendeskgarden/react-tags';

export type TagProps = {
  onClick?: Function;
  closeable?: boolean;
  onClose?: Function;
  focused?: boolean;
  hovered?: boolean;
  pill?: boolean;
  size?: 'small' | 'large';
  type?: 'grey' | 'blue' | 'kale' | 'red' | 'green' | 'yellow';
};

const Tag: React.SFC<TagProps> = ({
  children,
  closeable = false,
  onClose = () => {},
  ...props
}) => {
  return (
    <ZenTag {...props}>
      {children}
      {closeable ? <Close onClick={onClose} /> : null}
    </ZenTag>
  );
};

export default Tag;
