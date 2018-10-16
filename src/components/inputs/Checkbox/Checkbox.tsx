import * as React from 'react';
import { Checkbox as ZenCheckbox } from '@zendeskgarden/react-checkboxes';

export default function Checkbox({ children, ...props }) {
  return <ZenCheckbox {...props}>{children}</ZenCheckbox>;
}
