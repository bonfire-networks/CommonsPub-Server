import * as React from 'react';
import {
  Tabs as ZenTabs,
  TabPanel as ZenTabPanel
} from '@zendeskgarden/react-tabs';

export function Tabs({ children, ...props }) {
  return <ZenTabs {...props}>{children}</ZenTabs>;
}

export function TabPanel({ children, ...props }) {
  return <ZenTabPanel {...props}>{children}</ZenTabPanel>;
}
