```js
const { BrowserRouter } = require('react-router-dom');

const author = {
  name: 'Moodler Joe',
  avatarImage: 'https://picsum.photos/100/100?random'
};

const comment = {
  body:
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' +
    'Nam eu velit eget tellus molestie ullamcorper sed non lorem. ' +
    'Maecenas tempus metus et diam sollicitudin sollicitudin. ' +
    'Nunc feugiat metus est, pulvinar gravida nibh volutpat sit amet. ' +
    'Mauris in massa vel erat congue rhoncus.',
  timestamp: Date.now() - 60 * 1000 * 5
};

<BrowserRouter>
  <div>
    <Comment author={author} comment={comment} />
    <Comment child author={author} comment={comment} />
  </div>
</BrowserRouter>;
```
