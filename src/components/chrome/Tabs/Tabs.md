```js
const { Tabs, TabPanel } = require('./Tabs.tsx');
const Button = require('../../elements/Button/Button').default;

<Tabs selectedKey="tab-1" button={<Button>Hanging button</Button>}>
  <TabPanel label="Tab" key="tab-1">
    Tab 1 content
  </TabPanel>
  <TabPanel label="Tab 2" key="tab-2">
    Tab 2 content
  </TabPanel>
  <TabPanel label="Tab 3" key="tab-3">
    Tab 3 content
  </TabPanel>
</Tabs>;
```
