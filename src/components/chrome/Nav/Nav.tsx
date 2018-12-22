import * as React from 'react';
import { withRouter } from 'react-router';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
  Nav as ZenNav,
  NavItem,
  NavItemText,
  NavItemIcon,
  SubNav,
  SubNavItem,
  SubNavItemText
} from '@zendeskgarden/react-chrome';
import { faTh, faUsers } from '@fortawesome/free-solid-svg-icons';
import { RouterProps } from 'react-router';

import styled from '../../../themes/styled';

const SubNavItemHeader = styled(SubNavItem)<any>`
  font-weight: bold;
  pointer-events: none;
  color: black !important;
  text-shadow: 1px 1px 0 rgba(255, 151, 0, 0.4);
  font-size: 1.25em !important;
`;

const SidebarWrapper = styled.div`
  width: 240px;
  display: flex;
`;
enum NavItems {
  Communities,
  Collections
}

enum SubNavItems {
  Featured,
  Yours,
  Following
}

const navPathnames = {
  [NavItems.Communities]: '/communities',
  [NavItems.Collections]: '/collections'
};

const subNavPathnames = {
  [SubNavItems.Featured]: '/featured',
  [SubNavItems.Yours]: '/yours',
  [SubNavItems.Following]: '/following'
};

const navMatch = new Map([
  [/^\/communities/, NavItems.Communities],
  [/^\/collections/, NavItems.Collections]
]);

const subNavMatch = new Map([
  [/^\/communities\/?$/, SubNavItems.Featured],
  [/^\/collections\/?$/, SubNavItems.Featured],
  [/^\/(communities|collections)\/featured/, SubNavItems.Featured],
  [/^\/(communities|collections)\/following/, SubNavItems.Following],
  [/^\/(communities|collections)\/yours/, SubNavItems.Yours]
]);

const subNavItems = {
  [NavItems.Communities]: ({ current, onClick }) => (
    <>
      <SubNavItemHeader>Communities</SubNavItemHeader>
      <SubNavItem
        current={current === SubNavItems.Featured}
        onClick={() => onClick(SubNavItems.Featured)}
      >
        <SubNavItemText>Featured</SubNavItemText>
      </SubNavItem>
      <SubNavItem
        current={current === SubNavItems.Yours}
        onClick={() => onClick(SubNavItems.Yours)}
      >
        <SubNavItemText>Yours</SubNavItemText>
      </SubNavItem>
    </>
  ),
  [NavItems.Collections]: ({ current, onClick }) => (
    <>
      <SubNavItemHeader>Collections</SubNavItemHeader>
      <SubNavItem
        current={current === SubNavItems.Featured}
        onClick={() => onClick(SubNavItems.Featured)}
      >
        <SubNavItemText>Featured</SubNavItemText>
      </SubNavItem>
      <SubNavItem
        current={current === SubNavItems.Following}
        onClick={() => onClick(SubNavItems.Following)}
      >
        <SubNavItemText>Following</SubNavItemText>
      </SubNavItem>
      <SubNavItem
        current={current === SubNavItems.Yours}
        onClick={() => onClick(SubNavItems.Yours)}
      >
        <SubNavItemText>Yours</SubNavItemText>
      </SubNavItem>
    </>
  )
};

/**
 * Left-side navigation menu that is always present, allows user to view
 * different pages of the application such as their collections and
 * communities.
 */
class Nav extends React.Component<RouterProps, {}> {
  state: any = {
    open: false,
    activeNav: null,
    activeSubNav: null
  };

  constructor(props) {
    super(props);

    for (const [re, item] of navMatch) {
      if (re.test(props.location.pathname)) {
        this.state.activeNav = item;
      }
    }
    for (const [re, item] of subNavMatch) {
      if (re.test(props.location.pathname)) {
        this.state.activeSubNav = item;
      }
    }

    if (!this.state.activeNav) {
      this.state.activeNav = NavItems.Communities;
    }

    this.toggleSubNav = this.toggleSubNav.bind(this);
  }

  toggleMenu() {
    this.setState({
      open: !this.state.open
    });
  }

  toggleNav(nav) {
    this.setState({
      activeNav: nav,
      activeSubNav: SubNavItems.Featured
    });
    this.props.history.push(
      navPathnames[nav] + subNavPathnames[SubNavItems.Featured]
    );
  }

  toggleSubNav(subNav) {
    this.setState({
      activeSubNav: subNav
    });
    this.props.history.push(
      navPathnames[this.state.activeNav] + subNavPathnames[subNav]
    );
  }

  render() {
    return (
      <SidebarWrapper>
        <ZenNav expanded={this.state.open}>
          <NavItem
            title="Communities"
            onClick={() => this.toggleNav(NavItems.Communities)}
            current={this.state.activeNav === NavItems.Communities}
          >
            <NavItemIcon>
              <FontAwesomeIcon icon={faUsers} />
            </NavItemIcon>
            <NavItemText>Communities</NavItemText>
          </NavItem>
          <NavItem
            title="Collections"
            onClick={() => this.toggleNav(NavItems.Collections)}
            current={this.state.activeNav === NavItems.Collections}
          >
            <NavItemIcon>
              <FontAwesomeIcon icon={faTh} />
            </NavItemIcon>
            <NavItemText>Collections</NavItemText>
          </NavItem>
        </ZenNav>
        <SubNav>
          {subNavItems[this.state.activeNav]({
            onClick: this.toggleSubNav,
            current: this.state.activeSubNav
          })}
        </SubNav>
      </SidebarWrapper>
    );
  }
}

export default withRouter(Nav as any);
