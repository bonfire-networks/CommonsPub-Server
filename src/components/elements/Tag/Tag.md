```js
const { default: Tag, TagContainer } = require('./Tag');

<TagContainer style={{ margin: 0 }}>
  <Tag
    closeable
    focused
    style={{ marginRight: '10px' }}
    onClick={() => alert('Tag close clicked')}
  >
    Selected
  </Tag>
  <Tag closeable onClick={() => alert('Tag close clicked')}>
    Unselected
  </Tag>
</TagContainer>;
```
