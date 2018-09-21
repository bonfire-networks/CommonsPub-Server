import * as React from 'react';
import { Menu as ZenMenu, Item } from '@zendeskgarden/react-menus';
import { Avatar } from '@zendeskgarden/react-avatars';

const avatar = require('../../../static/img/avatar.png');
const search = require('../../../static/img/search.png');
const notifications = require('../../../static/img/notifications.png');

export const Menu = () => (
  <div className="Menu">
    <div className="Menu__item">
      <ZenMenu
        trigger={({ ref }) => (
          <img ref={ref} width={30} height={30} src={search} alt="Search" />
        )}
      >
        <Item>1</Item>
        <Item>2</Item>
        <Item>3</Item>
      </ZenMenu>
    </div>
    <div className="Menu__item">
      <ZenMenu
        trigger={({ ref }) => (
          <img
            ref={ref}
            width={30}
            height={30}
            src={notifications}
            alt="Notifications"
          />
        )}
      >
        <Item>1</Item>
        <Item>2</Item>
        <Item>3</Item>
      </ZenMenu>
    </div>
    <div className="Menu__item">
      <ZenMenu
        trigger={({ ref }) => (
          <Avatar innerRef={ref}>
            <img src={avatar} alt="Joe Bloggs" />
          </Avatar>
        )}
      >
        <Item>Your Profile</Item>
        <Item>Settings</Item>
        <Item>About MoodleNet</Item>
        <Item>Sign out</Item>
      </ZenMenu>
    </div>
  </div>
);
