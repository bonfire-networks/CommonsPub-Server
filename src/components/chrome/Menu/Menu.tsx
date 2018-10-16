import * as React from 'react';
import OnClickOutside from 'react-click-outside';
import compose from 'recompose/compose';
import { graphql } from 'react-apollo';
import { withTheme } from '@zendeskgarden/react-theming';

import NotificationsMenuBody from './Notifications.MenuBody';
import SearchMenuBody from './Search.MenuBody';
import UserMenuBody from './User.MenuBody';
import User from '../../../types/User';
import styled, { StyledThemeInterface } from '../../../themes/styled';
import MenuNav, { MenuItems } from './MenuNav';
import { faTimes } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const { GetUserQuery } = require('../../../graphql/GET_USER.client.graphql');

//TODO replace with some utility like lodash or polyfill `Object.values`
function values(obj) {
  return Object.keys(obj).map(k => obj[k]);
}

interface MenuContainerProps {
  show?: boolean;
  open?: boolean;
}

const MenuContainer = styled.div`
  width: 300px;
  left: ${(props: MenuContainerProps) => (props.open ? 0 : 300)}px;
  overflow: hidden;
`;

interface MenuBodyProps {
  width: number;
  open: boolean;
}

const MenuBody = styled.div<MenuBodyProps>`
  width: ${props => props.width}px;
  padding: 60px 10px 0 10px;
  height: 100%;
  overflow: auto;
  z-index: 10;
  position: fixed;
  box-shadow: 0 0 10px lightgrey;
  background-color: ${props => props.theme.styles.colour.base5};
  border-left: 1px solid ${props => props.theme.styles.colour.base4};
  right: ${props => (props.open ? 0 : -Math.max(...values(menuWidths)))}px;
  transition: all 0.2s ease-in-out;
`;

const MenuBodyInner = styled.div<any>`
  width: ${props => props.width}px;
  padding-top: 10px;
  border-top: 1px solid ${props => props.theme.styles.colour.base4};
`;

const MenuClose = styled.div`
  cursor: pointer;
  position: absolute;
  top: 12px;
  left: 14px;
  font-size: 29px;
  color: grey;

  &:active {
    color: black;
  }
`;

const menuWidths = {
  [MenuItems.notifications]: 280, // size of a Notification +  20px for padding
  [MenuItems.search]: 350,
  [MenuItems.user]: 260
};

interface MenuProps extends StyledThemeInterface {
  data: {
    //TODO use actual User type from graphql once defined, if possible
    user: {
      data: any;
      isAuthenticated: boolean;
    };
  };
  show?: boolean;
}

interface MenuState {
  openMenuName: string | null;
  open: boolean;
}

class Menu extends React.Component<MenuProps, MenuState> {
  state = {
    openMenuName: null,
    open: false
  };

  constructor(props: MenuProps) {
    super(props);
    this.toggleMenu = this.toggleMenu.bind(this);
    this.closeMenu = this.closeMenu.bind(this);
  }

  closeMenu() {
    // don't unset openMenuName otherwise the menu body content
    // will disappear as the menu closes
    this.setState({
      open: false
    });
  }

  toggleMenu(menuName) {
    if (this.state.openMenuName === menuName) {
      this.closeMenu();
    }

    this.setState({
      openMenuName: menuName,
      open: true
    });
  }

  getMenuBodyComponent() {
    const activeMenu = this.state.openMenuName;
    if (!activeMenu) {
      return null;
    }
    const Component = {
      [MenuItems.notifications]: NotificationsMenuBody,
      [MenuItems.search]: SearchMenuBody,
      [MenuItems.user]: UserMenuBody
    }[activeMenu] as React.ComponentType<{ user: User }>;
    return <Component user={this.props.data.user.data as User} />;
  }

  render() {
    // we use this to set the menu container width AND the inner menu
    // body width. we set the inner menu body width to prevent its content
    // being fluid on resize of the container when the user navigates
    // between menus that are different sizes, e.g. move from search to notifs
    const menuWidth = menuWidths[String(this.state.openMenuName)] || 300;

    return (
      <OnClickOutside style={{ width: 0 }} onClickOutside={this.closeMenu}>
        <MenuContainer show={this.props.show} open={this.state.open}>
          <MenuNav
            fixed={true}
            user={this.props.data.user}
            toggleMenu={this.toggleMenu}
          />
          <MenuBody width={menuWidth} open={this.state.open}>
            <MenuClose
              title={`Close the ${this.state.openMenuName} menu`}
              onClick={this.closeMenu}
            >
              <FontAwesomeIcon icon={faTimes} />
            </MenuClose>
            <MenuNav
              fixed={false}
              user={this.props.data.user}
              activeMenu={this.state.open ? this.state.openMenuName : null}
              toggleMenu={this.toggleMenu}
            />
            <MenuBodyInner width={menuWidth - 20}>
              {this.getMenuBodyComponent()}
            </MenuBodyInner>
          </MenuBody>
        </MenuContainer>
      </OnClickOutside>
    );
  }
}

export default compose(
  withTheme,
  graphql(GetUserQuery)
)(Menu);
