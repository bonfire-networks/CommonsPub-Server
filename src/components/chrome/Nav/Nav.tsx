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
        <Feedback target="blank" href="https://changemap.co/moodle/moodlenet">
          <Trans>🔬 Share Feedbacks</Trans>
        </Feedback>
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
            <Item>Home</Item>
          </NavLink>
        </NavList>
        <NavList>
          <Title>Communities</Title>
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
              <Trans>All Communities</Trans>
            </Item>
          </NavLink>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/communities/11` ||
                location.pathname === `/communities/11`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#f98012'
            }}
            to={'/communities/11'}
          >
            <Item>
              <Trans>The Lounge</Trans>
            </Item>
          </NavLink>
          <NavLink
            isActive={(match, location) => {
              return (
                location.pathname === `/communities/12` ||
                location.pathname === `/communities/12`
              );
            }}
            activeStyle={{
              position: 'relative',
              color: '#f98012'
            }}
            to={'/communities/12'}
          >
            <Item>
              <Trans>El Salón</Trans>
            </Item>
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
              <Trans>All Collections</Trans>
            </Item>
          </NavLink>
        </NavList>

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
  height: 30px;
  background: rgb(255, 239, 217);
  border-bottom: 1px solid rgb(228, 220, 195);
  color: #10100cc2 !important;
  line-height: 30px;
  padding: 0;
  font-size: 13px;
  text-decoration: none;
  margin-top: -18px;
  margin: -18px -16px;
  font-size: 13px;
  font-weight: 700;
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
