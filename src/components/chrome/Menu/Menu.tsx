import * as React from 'react';
import { Menu as ZenMenu, Item } from '@zendeskgarden/react-menus';
import { Avatar } from '@zendeskgarden/react-avatars';

import styled from '../../../themes/styled';

const avatar = require('../../../static/img/avatar.png');
const search = require('../../../static/img/search.png');
const notifications = require('../../../static/img/notifications.png');

interface MenuContainerProps {
  show?: boolean;
  open?: boolean;
}

const MenuContainer = styled.div`
  order: 3;
  max-width: 300px;
  width: ${(props: MenuContainerProps) => (props.open ? '25%' : '0%')};
`;

const MenuNav = styled.ul`
  position: fixed;
  top: 0;
  right: 0;
  list-style-type: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: row;
`;

const MenuNavItem = styled.li``;

const MenuBody = styled.div``;

interface MenuProps {
  show?: boolean;
}

interface MenuState {
  openMenuName: string | null;
  open: boolean;
}

export default class extends React.Component<MenuProps, MenuState> {
  state = {
    openMenuName: null,
    open: false
  };

  constructor(props: MenuProps) {
    super(props);
    this.toggleMenu = this.toggleMenu.bind(this);
  }

  toggleMenu(menuName) {
    if (this.state.openMenuName === menuName) {
      this.setState({
        openMenuName: null,
        open: false
      });
    }

    this.setState({
      openMenuName: menuName,
      open: true
    });
  }

  render() {
    return (
      <MenuContainer show={this.props.show} open={this.state.open}>
        <MenuNav>
          <MenuNavItem onClick={() => this.toggleMenu('Search')}>
            <img width={30} height={30} src={search} alt="Search" />
          </MenuNavItem>
          <MenuNavItem>
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
          </MenuNavItem>
          <MenuNavItem>
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
          </MenuNavItem>
        </MenuNav>
        <MenuBody>menu body</MenuBody>
      </MenuContainer>
    );
  }
}
