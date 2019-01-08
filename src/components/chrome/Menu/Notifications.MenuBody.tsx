import * as React from 'react';
import Notification, {
  NotificationType
} from '../../elements/Notification/Notification';
// TODO get user notifications from graphql and display here
export default ({ user }) => {
  return (
    <div>
      <Notification
        type={NotificationType.collection}
        when={'28-12-18'}
        content={'test'}
      />
    </div>
  );
};
