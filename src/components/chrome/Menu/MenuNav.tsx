import * as React from 'react';
import { Tooltip } from '@zendeskgarden/react-tooltips';
import { Avatar } from '@zendeskgarden/react-avatars';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCircle, faSearch } from '@fortawesome/free-solid-svg-icons';

import styled, { withTheme } from '../../../themes/styled';

const avatar = require('../../../static/img/avatar.png');

const MenuNav = styled.ul<any>`
  position: ${props => (props.fixed ? 'fixed' : 'absolute')};
  top: 0;
  right: 0;
  list-style-type: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: row;
  font-size: 29px;
`;

const MenuNavItem = styled.li<any>`
  cursor: pointer;
  padding: 10px;
  color: ${props =>
    props.active
      ? props.theme.styles.colour.primary
      : props.theme.styles.colour.primaryAlt};
  transition: color 0.2s ease;
`;

const NotifCount = styled.div`
  font-weight: bold;
  position: absolute;
  color: white;
  top: 50%;
  font-size: 13px;
  line-height: 1;
  left: 50%;
  transform: translate(-50%, -50%);
`;

const NotifMenuNavItem = styled(MenuNavItem)`
  position: relative;
`;

const NotifMenuNavItemTrigger = styled.div`
  user-select: none;

  &:active,
  &:focus {
    outline: 0;
  }
`;

export enum MenuItems {
  notifications = 'notifications',
  search = 'search',
  user = 'user'
}

export default withTheme(
  ({ fixed, toggleMenu, user, theme, activeMenu }: any) => {
    return (
      <MenuNav fixed={fixed}>
        <MenuNavItem
          active={activeMenu === MenuItems.search}
          onClick={() => toggleMenu(MenuItems.search)}
        >
          <FontAwesomeIcon icon={faSearch} />
        </MenuNavItem>
        <NotifMenuNavItem
          active={activeMenu === MenuItems.notifications}
          onClick={() => toggleMenu(MenuItems.notifications)}
        >
          <Tooltip
            placement="bottom"
            trigger={
              <NotifMenuNavItemTrigger>
                <FontAwesomeIcon icon={faCircle} />
                <NotifCount>{user.data.notifications.length}</NotifCount>
              </NotifMenuNavItemTrigger>
            }
          >
            <div style={{ textAlign: 'center', fontWeight: 'bold' }}>
              {user.data.notifications.length} unread notifications
            </div>
          </Tooltip>
        </NotifMenuNavItem>
        <MenuNavItem
          style={{ paddingLeft: 7 }}
          active={activeMenu === MenuItems.user}
          onClick={() => toggleMenu(MenuItems.user)}
        >
          <Avatar>
            <img
              style={{
                position: 'relative',
                top: '-2px'
              }}
              src={avatar}
              alt={user.data.username}
              title={`Hi, ${user.data.username}!`}
            />
          </Avatar>
        </MenuNavItem>
      </MenuNav>
    );
  }
);
