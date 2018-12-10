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

/**
 * Tag component.
 * @param children {JSX.Element} children of the tag
 * @param closeable {Boolean} display a cross next to tag text?
 * @param [onClose] {Function} on tag click callback, i.e. user "closes" the tag
 * @param props {Object} props of the tag
 * @constructor
 */
function Tag({ children, closeable = false, onClose = () => {}, ...props }) {
  return (
    <ZenTag {...props}>
      {children}
      {closeable ? <Close onClick={onClose} /> : null}
    </ZenTag>
  );
}

/**
 * Tag container component.
 */
export const TagContainer = styled.div`
  min-height: 55px;
  margin: 0 0 10px 0;

  ${ZenTag} {
    margin: 0 10px 10px 0;
  }
`;

export default Tag;
