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
    height: 40px;
    border-bottom-left-radius: 0;
    border-bottom-right-radius: 0;
  }
`;

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

export function TabPanel({ children, ...props }) {
  return <ZenTabPanel {...props}>{children}</ZenTabPanel>;
}
