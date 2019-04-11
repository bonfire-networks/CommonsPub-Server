import React from 'react';
import styled from '../../themes/styled';
import { Community, Collection } from '../elements/Icons';
import { Trans } from '@lingui/macro';
import OutsideClickHandler from 'react-outside-click-handler';
import Logo from '../brand/Logo/Logo';
const { getUserQuery } = require('../../graphql/getUserBasic.graphql');
import { graphql, OperationOption } from 'react-apollo';
import { clearFix } from 'polished';
import { compose, withHandlers, withState } from 'recompose';
import NewCommunityModal from '../../components/elements/CreateCommunityModal';
import SettingsModal from '../../components/elements/SettingsModal';
import Link from '../elements/Link/Link';
import media from 'styled-media-query';
import { NavLink } from 'react-router-dom';
import { useTheme } from '../../styleguide/Wrapper';
import Loader from '../../components/elements/Loader/Loader';

interface Props {
  handleOpen(): boolean;
  closeMenu(): boolean;
  isOpen: boolean;
  logout(): any;
  history: any;
  data: any;
  handleNewCommunity(): boolean;
  isOpenCommunity: boolean;
  handleSettings(): boolean;
  isOpenSettings: boolean;

  sidebar: boolean;
  onSidebar(boolean): boolean;
}

const Header: React.SFC<Props> = props => {
  const themeState = useTheme();
  return (
    <Wrapper>
      {props.data.error ? (
        <span>
          <Trans>Error loading collections</Trans>
        </span>
      ) : props.data.loading ? (
        <Loader />
      ) : (
        <>
          <Left>
            {/* <span onClick={() => props.onSidebar(!props.sidebar)}>
          <Menu width={18} height={18} color={'#68737d'} strokeWidth={2} />
        </span> */}

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
              <i>
                <Community
                  width={18}
                  height={18}
                  color={'#3d3f4a80'}
                  strokeWidth={2}
                />
              </i>
              <span>
                <Trans>Communities</Trans>
              </span>
            </NavLink>
            <NavLink
              isActive={(match, location) => {
                return (
                  location.pathname === `/collections` ||
                  location.pathname === `/collections/`
                );
              }}
              activeStyle={{
                position: 'relative',
                color: '#fff'
              }}
              to={'/collections'}
            >
              <i>
                <Collection
                  width={18}
                  height={18}
                  color={'#3d3f4a80'}
                  strokeWidth={2}
                />
              </i>
              <span>
                <Trans>Collections</Trans>
              </span>
            </NavLink>
          </Left>
          <Center>
            <Logo />
          </Center>
          <Right>
            <AvatarUsername onClick={props.handleOpen}>
              <span>{props.data.me.user.name}</span>
              <Avatar>
                <img
                  src={
                    props.data.me.user.icon ||
                    `https://www.gravatar.com/avatar/${
                      props.data.me.user.localId
                    }?f=y&d=identicon`
                  }
                  alt="Avatar"
                />
              </Avatar>
            </AvatarUsername>
            <Bottom onClick={props.handleNewCommunity}>
              <span>
                <Community
                  width={18}
                  height={18}
                  color={'#fff'}
                  strokeWidth={2}
                />
              </span>
            </Bottom>
          </Right>
          {props.isOpen ? (
            <>
              <OutsideClickHandler onOutsideClick={props.closeMenu}>
                <WrapperMenu>
                  <ProfileMenu>
                    <List lined>
                      <Item>
                        <Link to="/profile">
                          <Trans>Profile</Trans>
                        </Link>
                      </Item>
                      <Item onClick={props.handleSettings}>
                        <Trans>Settings</Trans>
                      </Item>
                      <Item onClick={() => themeState.toggle()}>
                        {themeState.dark
                          ? 'Switch to Light Mode'
                          : 'Switch to Dark Mode'}
                      </Item>
                    </List>
                    <List>
                      <Item>
                        <a
                          href="https://docs.moodle.org/dev/MoodleNet/Code_of_Conduct"
                          target="blank"
                        >
                          <Trans>Code of conduct</Trans>
                        </a>
                      </Item>
                      <Item onClick={props.logout}>
                        <Trans>Sign out</Trans>
                      </Item>
                    </List>
                  </ProfileMenu>
                </WrapperMenu>
              </OutsideClickHandler>
              <Layer />
            </>
          ) : null}
          <NewCommunityModal
            toggleModal={props.handleNewCommunity}
            modalIsOpen={props.isOpenCommunity}
          />
          <SettingsModal
            toggleModal={props.handleSettings}
            modalIsOpen={props.isOpenSettings}
            profile={props.data.me.user}
          />
        </>
      )}
    </Wrapper>
  );
};
const AvatarUsername = styled.div`
  float: left;
  line-height: 32px;
  margin-left: 16px;
  font-size: 13px;
  font-weight: 500;
  color: ${props => props.theme.styles.colour.headerLink};
  cursor: pointer;
  & span {
    float: left;
    margin-right: 8px;
  }
`;
const Center = styled.span`
  position: absolute;
  left: 50%;
  margin-left: -92px;
  & h1 {
    margin: 0;
    line-height: 50px;
  }
`;
const Bottom = styled.div`
  background: ${props => props.theme.styles.colour.primaryDark};
  border-radius: 4px;
  text-align: center;
  line-height: 30px;
  cursor: pointer;
  color: #fff;
  font-size: 13px;
  font-weight: 600;
  float: left;
  margin: 0;
  padding: 0 10px;
  font-size: 1.2em;
  font-weight: 400;
  text-decoration: none;
  outline: none;
  border: none;
  border-radius: 4px;
  transition: background 0.1s ease;
  cursor: pointer;
  margin-left: 16px;
  & span {
    vertical-align: sub;
    display: inline-block;
    ${media.lessThan('medium')`
    margin-right: 0;
    `};
  }
`;

const Wrapper = styled.div`
  height: 50px;
  min-height: 50px;
  background: ${props => props.theme.styles.colour.header};
  ${clearFix()};
  position: relative;
`;

const Avatar = styled.div`
  width: 32px;
  height: 32px;
  border-radius: 100px;
  overflow: hidden;
  margin-right: 8px;
  background: ${props => props.theme.styles.colour.background};
`;

const WrapperMenu = styled.div`
  box-sizing: border-box;
  width: 20em;
  padding: 5px;
  border-radius: 0.25em;
  background-color: rgb(232, 232, 232);
  position: absolute;
  top: 50px;
  right: 10px;
  z-index: 999999999999;
`;

const Layer = styled.div`
  position: absolute;
  left: 0;
  right: 0;
  top: 0px;
  height: 50px;
  z-index: 1;
  display: block;
`;

const ProfileMenu = styled.div`
  background: #fff;
  box-shadow: 0 1px 1px rgba(0, 0, 0, 0.1);
`;
const List = styled.div<{ lined?: boolean }>`
  padding: 8px;
  border-bottom: ${props => (props.lined ? '1px solid #dadada' : null)};
`;
const Item = styled.div`
  font-size: 14px;
  line-height: 30px;
  height: 30px;
  cursor: pointer;
  font-weight: 600;
  color: ${props => props.theme.styles.colour.base3};
  & a {
    color: inherit !important;
    text-decoration: none;
  }
  &:hover {
    color: rgba(0, 0, 0, 0.9);
  }
`;
const Left = styled.div`
  float: left;
  line-height: 50px;
  height: 50px;
  max-height: 50px;
  margin-left: 16px;
  & a {
    font-weight: 600;
    font-size: 12px;
    text-transform: uppercase;
    color: ${props => props.theme.styles.colour.headerLink};
    text-decoration: none;
    margin-right: 32px;

    & i {
      margin-right: 8px;
      & svg {
        vertical-align: sub;
        color: inherit !important;
      }
    }
  }

  & input {
    border: 0px solid !important;
    border-radius: 100px;
    height: 34px;
    max-height: 34px;
    min-height: 34px;
    background: #f6f6f6;
  }
`;
const Right = styled.div`
  float: right;
  margin-top: 9px;
  margin-right: 16px;
  ${clearFix()};
  & img {
    cursor: pointer;
    max-width: 32px;
    max-height: 32px;
  }
`;

const withGetUser = graphql<
  {},
  {
    data: {
      me: any;
    };
  }
>(getUserQuery) as OperationOption<{}, {}>;

export default compose(
  withGetUser,
  withState('isOpen', 'onOpen', false),
  withState('isOpenSettings', 'onOpenSettings', false),
  withState('isOpenCommunity', 'onOpenCommunity', false),
  withHandlers({
    handleOpen: props => () => props.onOpen(true),
    handleSettings: props => () => props.onOpenSettings(!props.isOpenSettings),
    handleNewCommunity: props => () =>
      props.onOpenCommunity(!props.isOpenCommunity),
    closeMenu: props => () => props.onOpen(false),
    logout: props => () => {
      localStorage.removeItem('user_access_token');
      localStorage.removeItem('dark');
      return window.location.reload();
    }
  })
)(Header);
