import React from 'react';
import styled from '../../themes/styled';
import { Community, Collection } from '../elements/Icons';
import { Trans } from '@lingui/macro';
import OutsideClickHandler from 'react-outside-click-handler';
// import Text from '../inputs/Text/Text';
import Logo from '../brand/Logo/Logo';
const { getUserQuery } = require('../../graphql/getUser.client.graphql');
import { graphql } from 'react-apollo';
import { clearFix } from 'polished';
import { compose, withHandlers, withState } from 'recompose';
// import LanguageSelect from '../../components/inputs/LanguageSelect/LanguageSelect';
import NewCommunityModal from '../../components/elements/CreateCommunityModal';
import SettingsModal from '../../components/elements/SettingsModal';
import Link from '../elements/Link/Link';
import { Menu } from '../elements/Icons';
import media from 'styled-media-query';

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
  return (
    <Wrapper>
      <Left>
        <span onClick={() => props.onSidebar(!props.sidebar)}>
          <Menu width={18} height={18} color={'#68737d'} strokeWidth={2} />
        </span>
        <Link to="/communities">
          <i>
            <Community
              width={18}
              height={18}
              color={'#3d3f4a80'}
              strokeWidth={2}
            />
          </i>
          <Trans>Communities</Trans>
        </Link>
        <Link to="/collections">
          <i>
            <Collection
              width={18}
              height={18}
              color={'#3d3f4a80'}
              strokeWidth={2}
            />
          </i>
          <Trans>Collections</Trans>
        </Link>
      </Left>
      <Center>
        <Logo />
      </Center>
      <Right>
        <Bottom onClick={props.handleNewCommunity}>
          <span>
            <Community width={18} height={18} color={'#fff'} strokeWidth={2} />
          </span>
        </Bottom>
        <AvatarUsername>
          <Avatar>
            <img
              onClick={props.handleOpen}
              src={
                props.data.user.data.icon ||
                `https://www.gravatar.com/avatar/${
                  props.data.user.data.localId
                }?f=y&d=identicon`
              }
              alt="Avatar"
            />
          </Avatar>
          {props.data.user.data.name}
        </AvatarUsername>
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
                </List>
                <List>
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
        profile={props.data.user.data}
      />
    </Wrapper>
  );
};
const AvatarUsername = styled.div`
  float: left;
  float: left;
  line-height: 32px;
  margin-left: 16px;
  font-size: 13px;
  font-weight: 500;
  color: #00002f;
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
  height: 30px;
  background: ${props => props.theme.styles.colour.primary};
  border-radius: 4px;
  text-align: center;
  line-height: 30px;
  cursor: pointer;
  color: #fff;
  font-size: 13px;
  font-weight: 600;
  float: left;
  padding: 0 16px;
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
  background: #fff;
  ${clearFix()};
  position: relative;
`;

const Avatar = styled.div`
  width: 32px;
  height: 32px;
  border-radius: 100px;
  overflow: hidden;
  margin-right: 8px;
  float: left;
  background: #e6e6e6;
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
  z-index: 9999;
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
  color: rgba(0, 0, 0, 0.6);
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
    color: #3d3f4a80 !important;
    text-decoration: none;
    margin-right: 24px;
    & i {
      margin-right: 8px;
      & svg {
        vertical-align: middle;
      }
    }
  }
  & span {
    float: left;
    line-height: 30px;
    cursor: pointer;
    display: none;
    ${media.lessThan('medium')`
    display: block;
    & svg {
      vertical-align: middle;
      margin-right: 8px;
    }
    `}
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

// const LanguageSelect = styled.div`
//   display: inline-block;
// `;

export default compose(
  graphql(getUserQuery),
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
      return window.location.reload();
    }
  })
)(Header);
