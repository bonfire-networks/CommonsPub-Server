/**
 * TODO consider how notification icon gets set, as faUser is not releveant for e.g. moodlebot notification
 */
import * as React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faUser } from '@fortawesome/free-solid-svg-icons';

import styled from '../../../themes/styled';

export enum NotificationType {
  community = 'community',
  collection = 'collection',
  moodlebot = 'moodlebot'
}

interface NotificationProps {
  type: NotificationType;
  when: string;
  content: any;
}

interface NotificationStyleProps {
  type: NotificationType;
}

const typeColourMap = {
  [NotificationType.collection]: 'collection',
  [NotificationType.community]: 'community',
  [NotificationType.moodlebot]: 'primary'
};

const Notification = styled.div<NotificationStyleProps>`
  display: flex;
  flex-direction: column;
  margin: 0 20px 10px 0;
  width: 260px;
  min-height: 160px;
  background-color: white;
  box-shadow: 0 3px 5px lightgrey;
  padding: 10px;
  border-top: 3px solid
    ${props => props.theme.styles.colour[typeColourMap[props.type]]};
`;

const NotificationWhen = styled.div`
  color: ${props => props.theme.styles.colour.base3};
  font-weight: bold;
  font-size: 12px;
  margin: 0 50px 10px 50px;
`;

const NotificationHeading = styled.div`
  color: ${props => props.theme.styles.colour.base3};
  text-transform: uppercase;
  font-weight: bold;
  font-size: 12px;
  margin-left: 50px;
`;

const NotificationIcon = styled.div`
  margin-block-start: 1em;
  margin-block-end: 1em;
  height: 40px;
  width: 40px;
  background-color: ${props => props.theme.styles.colour.base3};
  border-radius: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 16px;
`;

const NotificationContent = styled.div`
  display: flex;
  flex-grow: 1;
  font-size: 15px;
`;

const NotificationContentInner = styled.div`
  width: 200px;
  margin-left: 10px;
`;

/**
 * Loader component.
 * @param type {NotificationType} notification type
 * @param content {String} notification inner content, i.e. message
 * @param when {String} when notification was received
 * @param props {Object} props of the notification
 */
export default function({
  type,
  content,
  when,
  ...props
}: NotificationProps): JSX.Element {
  return (
    <Notification type={type} {...props}>
      <NotificationHeading>{type.toUpperCase()}</NotificationHeading>
      <NotificationContent>
        <NotificationIcon>
          <FontAwesomeIcon icon={faUser} />
        </NotificationIcon>
        {/*TODO don't use dangerouslySetInnerHTML!!!*/}
        <NotificationContentInner
          dangerouslySetInnerHTML={{ __html: content }}
        />
      </NotificationContent>
      <NotificationWhen>{when}</NotificationWhen>
    </Notification>
  );
}
