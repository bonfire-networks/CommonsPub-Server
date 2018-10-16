```js
const { default: Notification, NotificationType } = require('./Notification');

<div
  style={{
    display: 'flex',
    flexDirection: 'row',
    flexWrap: 'wrap'
  }}
>
  <Notification
    type={NotificationType.community}
    when="Just now"
    content={`
      <p>
        <strong>Liezel</strong> commented on your post in
        <strong>Progressive European Historians</strong>
      </p>
    `}
  />
  <Notification
    type={NotificationType.collection}
    when="12 minutes ago"
    content={`
      <p>
        <strong>Ibrahima</strong> commented on the collection
        <strong>Hyperinflation in Weimar Germany</strong>
      </p>
    `}
  />
  <Notification
    type={NotificationType.moodlebot}
    when="5 hours ago"
    content={`
      <p>
        We think you might find the collection
        <strong>Lenin at Finland Station</strong> interesting
      </p>
    `}
  />
</div>;
```
