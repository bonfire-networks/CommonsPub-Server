import * as React from 'react';
import { withRouter } from 'react-router';
import { RouterProps } from 'react-router';
import { NavLink } from 'react-router-dom';
import styled from '../../../themes/styled';
import { compose, withState, withHandlers } from 'recompose';
import NewCommunityModal from '../../elements/CreateCommunityModal';

import { Trans } from '@lingui/macro';

const SidebarWrapper = styled.div`
  width: 240px;
  display: flex;
  flex-direction: column;
  padding: 16px;
  position: relative;
  background: whitesmoke;
`;

interface NavProps extends RouterProps {
  handleNewCommunity(): boolean;
  isOpen: boolean;
}
/**
 * Left-side navigation menu that is always present, allows user to view
 * different pages of the application such as their collections and
 * communities.
 */
class Nav extends React.Component<NavProps, {}> {
  render() {
    return (
      <SidebarWrapper>
        <NavList>
          <NavLink
            isActive={(match, location) => {
              return location.pathname === `/`;
            }}
            activeStyle={{
              position: 'relative',
              color: '#f98012'
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
          {/* <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/communities/featured/` ||
                location.pathname === `/communities/featured`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#f98012'
            }}
            to={'/communities/featured'}
          >
            <Item>Featured</Item>
          </NavLink> */}

          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/communities` ||
                location.pathname === `/communities/`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#f98012'
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
              color: '#f98012'
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
                location.pathname === `/communities/7` ||
                location.pathname === `/communities/7`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#f98012'
            }}
            to={'/communities/7'}
          >
            <Item>The Lounge</Item>
          </NavLink>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/communities/15` ||
                location.pathname === `/communities/15`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#f98012'
            }}
            to={'/communities/15'}
          >
            <Item>El Salón</Item>
          </NavLink>
        </NavList>
        <NavList>
          <Title>
            <Trans>Collections</Trans>
          </Title>
          {/* <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/collections/featured` ||
                location.pathname === `/collections/featured/`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#f98012'
            }}
            to={'/collections/featured'}
          >
            <Item>Featured</Item>
          </NavLink> */}
          {/* <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/collections/following/` ||
                location.pathname === `/collections/following`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#f98012'
            }}
            to={'/collections/following'}
          >
            <Item>Following</Item>
          </NavLink> */}
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/collections/` ||
                location.pathname === `/collections`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#f98012'
            }}
            to={'/collections'}
          >
            <Item>
              <Trans>All</Trans>
            </Item>
          </NavLink>
        </NavList>
        <Feedback target="blank" href="https://changemap.co/moodle/moodlenet">
          <Trans>🔬 Share Feedback</Trans>
        </Feedback>

        <Bottom onClick={this.props.handleNewCommunity}>
          <Trans>Create a community</Trans>
        </Bottom>
        <NewCommunityModal
          toggleModal={this.props.handleNewCommunity}
          modalIsOpen={this.props.isOpen}
        />
      </SidebarWrapper>
    );
  }
}

const Feedback = styled.a`
  display: block;
  text-align: center;
  animation: 0.5s slide-in;
  position: relative;
  height: 40px;
  background: rgb(255, 239, 217);
  border-bottom: 1px solid rgb(228, 220, 195);
  color: #10100cc2 !important;
  line-height: 30px;
  padding: 5px 0;
  font-size: 13px;
  text-decoration: none;
  font-weight: 700;
  margin-top: 18px;
  margin-bottom: 16px;
  cursor: pointer;
  &:hover {
    background: rgb(245, 229, 207);
  }
`;

const Bottom = styled.div`
  position: absolute;
  bottom: 10px;
  height: 60px;
  background: ${props => props.theme.styles.colour.primary};
  border-radius: 4px;
  text-align: center;
  left: 10px;
  right: 10px;
  line-height: 60px;
  cursor: pointer;
  color: #fff;
  font-size: 14px;
  font-weight: 600;
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
`;
const Title = styled.div`
  font-size: 11px;
  text-transform: uppercase;
  font-weight: 500;
  margin-bottom: 12px;
  letter-spacing: 0.5px;
  color: ${props => props.theme.styles.colour.base3};
`;

const NavWithRouter = withRouter(Nav as any);

export default compose(
  withState('isOpen', 'onOpen', false),
  withHandlers({
    handleNewCommunity: props => () => props.onOpen(!props.isOpen)
  })
)(NavWithRouter);
