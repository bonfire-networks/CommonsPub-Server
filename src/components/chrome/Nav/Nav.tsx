import * as React from 'react';
import {
  Nav as ZenNav,
  NavItem,
  NavItemText,
  NavItemIcon,
  SubNav,
  SubNavItem,
  SubNavItemText
} from '@zendeskgarden/react-chrome';

const logo = require('../../../static/img/moodle-logo.png');

enum NavItems {
  Communities,
  Collections
}

enum SubNavItems {
  Featured,
  Yours,
  Following
}

const subNavItems = {
  [NavItems.Communities]: ({ current }) => (
    <>
      <SubNavItem current={current === SubNavItems.Featured}>
        <SubNavItemText>Featured</SubNavItemText>
      </SubNavItem>
      <SubNavItem current={current === SubNavItems.Yours}>
        <SubNavItemText>Yours</SubNavItemText>
      </SubNavItem>
    </>
  ),
  [NavItems.Collections]: ({ current }) => (
    <>
      <SubNavItem current={current === SubNavItems.Featured}>
        <SubNavItemText>Featured</SubNavItemText>,
      </SubNavItem>
      <SubNavItem current={current === SubNavItems.Following}>
        <SubNavItemText>Following</SubNavItemText>,
      </SubNavItem>
      <SubNavItem current={current === SubNavItems.Yours}>
        <SubNavItemText>Yours</SubNavItemText>,
      </SubNavItem>
    </>
  )
};

export default class Nav extends React.Component {
  state: any = {
    navOpen: true,
    activeNav: NavItems.Communities,
    activeSubNav: SubNavItems.Featured
  };

  toggleMenu() {
    this.setState({
      navOpen: !this.state.navOpen
    });
  }

  render() {
    return (
      <>
        <ZenNav expanded={this.state.navOpen}>
          <NavItem logo title="MoodleNet" onClick={() => this.toggleMenu()}>
            <NavItemIcon>
              <img src={logo} />
            </NavItemIcon>
            <NavItemText>MoodleNet</NavItemText>
          </NavItem>
          <NavItem
            title="Communities"
            current={this.state.activeNav === NavItems.Communities}
          >
            <NavItemText>Communities</NavItemText>
          </NavItem>
          <NavItem
            title="Collections"
            current={this.state.activeNav === NavItems.Collections}
          >
            <NavItemText>Collections</NavItemText>
          </NavItem>
        </ZenNav>
        <SubNav>
          {...subNavItems[this.state.activeNav]({
            current: this.state.activeSubNav
          })}
        </SubNav>
      </>
    );
  }
}
