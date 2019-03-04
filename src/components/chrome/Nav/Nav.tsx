import * as React from 'react';
import { withRouter } from 'react-router';
import { RouterProps } from 'react-router';
import { NavLink } from 'react-router-dom';
import styled from '../../../themes/styled';
import LanguageSelect from '../../inputs/LanguageSelect/LanguageSelect';
import { compose, withState, withHandlers } from 'recompose';
import media from 'styled-media-query';
import { Trans } from '@lingui/macro';

interface NavProps extends RouterProps {
  handleNewCommunity(): boolean;
  isOpen: boolean;
  sidebar: boolean;
}
/**
 * Left-side navigation menu that is always present, allows user to view
 * different pages of the application such as their collections and
 * communities.
 */
class Nav extends React.Component<NavProps, {}> {
  render() {
    return (
      <SidebarWrapper sidebar={this.props.sidebar}>
        <NavList>
          <NavLink
            isActive={(match, location) => {
              return location.pathname === `/`;
            }}
            activeStyle={{
              position: 'relative',
              color: '#fff'
            }}
            to={'/'}
          >
            <Item>
              <Trans>Home</Trans>
            </Item>
          </NavLink>
        </NavList>
        <NavList>
          <Title>
            <Trans>Communities</Trans>
          </Title>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/communities` ||
                location.pathname === `/communities/`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#fff'
            }}
            to={'/communities'}
          >
            <Item>
              <Trans>All</Trans>
            </Item>
          </NavLink>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/communities/joined` ||
                location.pathname === `/communities/joined/`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#fff'
            }}
            to={'/communities/joined'}
          >
            <Item>
              <Trans>Joined</Trans>
            </Item>
          </NavLink>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/communities/featured` ||
                location.pathname === `/communities/featured/`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#fff'
            }}
            to={'/communities/featured'}
          >
            <Item>
              <Trans>Featured</Trans>
            </Item>
          </NavLink>
        </NavList>
        <NavList>
          <Title>
            <Trans>Collections</Trans>
          </Title>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/collections/` ||
                location.pathname === `/collections`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#fff'
            }}
            to={'/collections'}
          >
            <Item>
              <Trans>All</Trans>
            </Item>
          </NavLink>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/collections/following` ||
                location.pathname === `/collections/following/`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#fff'
            }}
            to={'/collections/following'}
          >
            <Item>
              <Trans>Following</Trans>
            </Item>
          </NavLink>
        </NavList>
        <Bottom>
          <LanguageSelect />
          <Feedback target="blank" href="https://changemap.co/moodle/moodlenet">
            <Trans>🔬 Share Feedback</Trans>
          </Feedback>
        </Bottom>
      </SidebarWrapper>
    );
  }
}

const SidebarWrapper = styled.div<{ sidebar?: boolean }>`
  width: 240px;
  display: flex;
  flex-direction: column;
  padding: 16px;
  position: relative;
  background-color: #151b26;
  transition: margin-left 300ms ease-in-out;
  margin-left: 0;
  ${media.lessThan('medium')`
   margin-left: ${props => (props.sidebar ? 0 : '-240px')};
   transition: all 300ms ease-in-out;
   position: absolute;
   left: 0;
   top: 0;
   bottom: 0;
   z-index: 99999
  `};
`;

const Feedback = styled.a`
  display: block;
  text-align: left;
  padding-left: 8px;
  animation: 0.5s slide-in;
  position: relative;
  color: #fff !important;
  font-size: 14px;
  text-decoration: none;
  font-weight: 600;
  cursor: pointer;
`;

const Bottom = styled.div`
  position: absolute;
  bottom: 10px;
  max-height: 80px;
  text-align: center;
  left: 0px;
  right: 0px;
  line-height: 50px;
  padding: 0 14px;
  cursor: pointer;
  color: #fff;
  font-size: 14px;
  font-weight: 600;
  ${media.lessThan('medium')`
  display: none;
  `};
`;

const NavList = styled.div`
  margin-bottom: 24px;
  & a {
    text-decoration: none;
    color: ${props => props.theme.styles.colour.base2};
    margin-bottom: 8px;
    display: block;

    &: before {
      position: absolute;
      content: '';
      left: -16px;
      top: 0;
      bottom: 0;
      width: 4px;
      display: block;
      background: ${props => props.theme.styles.colour.primary};
      height: 20px;
    }
  }
`;
const Item = styled.div`
  font-size: 13px;
  font-weight: 600;
  color: inherit;
  letter-spacing: 1px;
  color: #f0f0f0e6;
`;
const Title = styled.div`
  font-size: 11px;
  text-transform: uppercase;
  font-weight: 700;
  margin-bottom: 12px;
  letter-spacing: 0.5px;
  color: #ffffffb3;
`;

const NavWithRouter = withRouter(Nav as any);

export default compose(
  withState('isOpen', 'onOpen', false),
  withHandlers({
    handleNewCommunity: props => () => props.onOpen(!props.isOpen)
  })
)(NavWithRouter);
