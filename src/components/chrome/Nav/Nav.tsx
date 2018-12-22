import * as React from 'react';
import { withRouter } from 'react-router';
import { RouterProps } from 'react-router';
import { NavLink } from 'react-router-dom';
import Logo from '../../brand/Logo/Logo';
import styled from '../../../themes/styled';

const SidebarWrapper = styled.div`
  width: 240px;
  display: flex;
  flex-direction: column;
  padding: 16px;
  position: relative;
  background: ${props => props.theme.styles.colour.primary};
`;

/**
 * Left-side navigation menu that is always present, allows user to view
 * different pages of the application such as their collections and
 * communities.
 */
class Nav extends React.Component<RouterProps, {}> {
  render() {
    return (
      <SidebarWrapper>
        <Logo />
        <NavList>
          <NavLink
            isActive={(match, location) => {
              return location.pathname === `/`;
            }}
            activeStyle={{
              position: 'relative',
              color: '#fff !important'
            }}
            to={'/'}
          >
            <Item>Home</Item>
          </NavLink>
        </NavList>
        <NavList>
          <Title>Communities</Title>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/communities/featured/` ||
                location.pathname === `/communities/featured`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#fff !important'
            }}
            to={'/communities/featured'}
          >
            <Item>Featured</Item>
          </NavLink>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/communities` ||
                location.pathname === `/communities/`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#fff !important'
            }}
            to={'/communities'}
          >
            <Item>Yours</Item>
          </NavLink>
        </NavList>
        <NavList>
          <Title>Collections</Title>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/collections/featured` ||
                location.pathname === `/collections/featured/`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#fff !important'
            }}
            to={'/collections/featured'}
          >
            <Item>Featured</Item>
          </NavLink>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/collections/following/` ||
                location.pathname === `/collections/following`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#fff !important'
            }}
            to={'/collections/following'}
          >
            <Item>Following</Item>
          </NavLink>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/collections/` ||
                location.pathname === `/collections`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#fff !important'
            }}
            to={'/collections'}
          >
            <Item>Yours</Item>
          </NavLink>
        </NavList>

        <Bottom>New Community</Bottom>
      </SidebarWrapper>
    );
  }
}

const Bottom = styled.div`
  position: absolute;
  bottom: 0;
  height: 60px;
  border-top: 1px solid rgba(250, 250, 250, 0.2);
  left: 0;
  right: 0;
  line-height: 60px;
  color: #fff;
  font-size: 13px;
  text-align: center;
`;

const NavList = styled.div`
  margin-bottom: 24px;
  & a {
    text-decoration: none;
    color: #ffffffb5;
    &: before {
      position: absolute;
      content: '';
      left: -16px;
      top: 0;
      bottom: 0;
      width: 4px;
      display: block;
      background: #00ffca;
      height: 20px;
    }
  }
`;
const Item = styled.div`
  font-size: 13px;
  font-weight: 600;
  color: #ffffffd4;
  margin-bottom: 8px;
  letter-spacing: 1px;
`;
const Title = styled.div`
  font-size: 11px;
  text-transform: uppercase;
  font-weight: 500;
  margin-bottom: 12px;
  letter-spacing: 0.5px;
  color: #ffffffa1;
`;

export default withRouter(Nav as any);
