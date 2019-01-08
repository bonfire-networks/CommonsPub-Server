import * as React from 'react';
import {
  Tabs as ZenTabs,
  TabPanel as ZenTabPanel
} from '@zendeskgarden/react-tabs';

import styled from '../../../themes/styled';

const TabsWithButton = styled.div`
  position: relative;
`;

const TabsButton = styled.div`
  position: absolute;
  top: 0;
  right: 0;
  button {
    height: 30px;
    line-height: 27px;
    margin-top: 4px;
    margin-right: 8px;
    border: 2px solid #6b7a7d66 !important;
    color: #6b7a7d !important;
    border-radius: 100px;
    &:hover {
      background: #f3f3f3 !important;
    }
  }
`;

/**
 * Tabs component.
 * @param children {JSX.Element} children of tabs
 * @param button {JSX.Element} button to add on right side of tabs
 * @param props {Object} tabs component props
 * @constructor
 */
export function Tabs({ children, button, ...props }: any) {
  const tabs = <ZenTabs {...props}>{children}</ZenTabs>;
  if (button) {
    return (
      <TabsWithButton>
        {tabs}
        <TabsButton>{button}</TabsButton>
      </TabsWithButton>
    );
  }
  return tabs;
}

/**
 * TabsPanel component.
 * @param children {JSX.Element} children of tabs panel
 * @param props {Object} tabs panel props
 * @constructor
 */
export function TabPanel({ children, ...props }) {
  return <ZenTabPanel {...props}>{children}</ZenTabPanel>;
}
