import * as React from 'react';
import { Checkbox as ZenCheckbox } from '@zendeskgarden/react-checkboxes';

/**
 * Checkbox component.
 * @param children {JSX.Element} children of checkbox
 * @param props {Object} props of checkbox
 * @constructor
 */
export default function Checkbox({ children, ...props }) {
  return <ZenCheckbox {...props}>{children}</ZenCheckbox>;
}
