import * as React from 'react';
import { Tag as ZenTag, Close } from '@zendeskgarden/react-tags';

import styled from '../../../themes/styled';

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

export const TagContainer = styled.div`
  min-height: 55px;
  margin: 0 0 10px 0;

  ${ZenTag} {
    margin: 0 10px 10px 0;
  }
`;

export default Tag;
