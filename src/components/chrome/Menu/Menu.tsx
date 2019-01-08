import * as React from 'react';
// import OnClickOutside from 'react-click-outside';
import { compose, withState, withHandlers } from 'recompose';
import { graphql } from 'react-apollo';
import { withTheme } from '@zendeskgarden/react-theming';

import NotificationsMenuBody from './Notifications.MenuBody';
import User from '../../../types/User';
import styled, { StyledThemeInterface } from '../../../themes/styled';

const { getUserQuery } = require('../../../graphql/getUser.client.graphql');

const MenuContainer = styled.div`
  width: 280px;
  display: flex;
`;

const MenuBody = styled.div`
  width: 280px;
  padding: 10px;
  height: 100%;
  overflow: auto;
  z-index: 10;
  position: fixed;
  background-color: #fff;
  border-left: 1px solid ${props => props.theme.styles.colour.base4};
  transition: all 0.2s ease-in-out;
`;

const MenuBodyInner = styled.div<any>`
  padding-top: 10px;
`;

const Nav = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  grid-column-gap: 8px;
  margin-bottom: 16px;
`;

const Item = styled.div<{ isActive?: boolean }>`
  font-size: 11px;
  text-transform: uppercase;
  font-weight: 600;
  letter-spacing: 1px;
  position: relative;
  cursor: pointer;
  color: ${props => props.theme.styles.colour.base1};
  &:before {
    position: absolute;
    content: '';
    width: 24px;
    height: 3px;
    left: 50%;
    margin-left: -12px;
    bottom: -4px;
    display: ${props => (props.isActive ? 'block' : 'none')};
    background-color: ${props => props.theme.styles.colour.primary};
  }
`;

interface MenuProps extends StyledThemeInterface {
  data: {
    //TODO use actual User type from graphql once defined, if possible
    user: {
      data: any;
      isAuthenticated: boolean;
    };
  };
  active: string;
  onActive(string): string;
}

/**
 * The Menu component displays user notifications, the search menu,
 * and user options. There are two parts to the user menu. This is the
 * "main menu" that appears in from the right when the user clicks
 * on a MenuNav button.
 * @class
 */
class Menu extends React.Component<MenuProps> {
  render() {
    // we use this to set the menu container width AND the inner menu
    // body width. we set the inner menu body width to prevent its content
    // being fluid on resize of the container when the user navigates
    // between menus that are different sizes, e.g. move from search to notifs
    // const menuWidth = menuWidths[String(this.state.openMenuName)] || 300;

    return (
      <MenuContainer>
        <MenuBody>
          <Nav>
            <Item
              onClick={() => this.props.onActive('bot')}
              isActive={this.props.active === 'bot'}
            >
              MoodleBot
            </Item>
            <Item
              onClick={() => this.props.onActive('community')}
              isActive={this.props.active === 'community'}
            >
              Community
            </Item>
            <Item
              onClick={() => this.props.onActive('collection')}
              isActive={this.props.active === 'collection'}
            >
              Collection
            </Item>
          </Nav>
          <MenuBodyInner>
            <NotificationsMenuBody user={this.props.data.user.data as User} />
          </MenuBodyInner>
        </MenuBody>
      </MenuContainer>
    );
  }
}

export default compose(
  withTheme,
  graphql(getUserQuery),
  withState('active', 'isActive', 'bot'),
  withHandlers({
    onActive: props => type => props.isActive(type)
  })
)(Menu);
