import React from 'react';
import styled from '../../themes/styled';

import { Trans } from '@lingui/macro';
import OutsideClickHandler from 'react-outside-click-handler';
// import Text from '../inputs/Text/Text';
import Logo from '../brand/Logo/Logo';
const { getUserQuery } = require('../../graphql/getUser.client.graphql');
import { graphql } from 'react-apollo';
import { clearFix } from 'polished';
import { compose, withHandlers, withState } from 'recompose';
import LanguageSelect from '../../components/inputs/LanguageSelect/LanguageSelect';

interface Props {
  handleOpen(): boolean;
  closeMenu(): boolean;
  isOpen: boolean;
  logout(): any;
  history: any;
  data: any;
}

const Header: React.SFC<Props> = props => {
  return (
    <Wrapper>
      <Left>
        <Logo />
      </Left>
      <Right>
        <Left>
          <LanguageSelect />
        </Left>
        <Right>
          <Avatar>
            <img
              onClick={props.handleOpen}
              src={`https://www.gravatar.com/avatar/${
                props.data.user.data.localId
              }?f=y&d=identicon`}
              alt="Avatar"
            />
          </Avatar>
        </Right>
      </Right>
      {props.isOpen ? (
        <>
          <OutsideClickHandler onOutsideClick={props.closeMenu}>
            <WrapperMenu>
              <Menu>
                <List lined>
                  <Item>{props.data.user.data.name}</Item>
                  {/* <Item><Trans>Edit profile</Trans></Item>
            <Item><Trans>Settings</Trans></Item> */}
                </List>
                <List>
                  <Item onClick={props.logout}>
                    <Trans>Sign out</Trans>
                  </Item>
                </List>
              </Menu>
            </WrapperMenu>
          </OutsideClickHandler>
          <Layer />
        </>
      ) : null}
    </Wrapper>
  );
};

const Wrapper = styled.div`
  height: 50px;
  ${clearFix()};
  position: relative;
`;

const Avatar = styled.div`
  width: 32px;
  height: 32px;
  border-radius: 100px;
  overflow: hidden;
  margin-left: 10px;
  & img {
    width: 100%
    height: auto;
  }
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

const Menu = styled.div`
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

  &:hover {
    color: rgba(0, 0, 0, 0.9);
  }
`;
const Left = styled.div`
  float: left;
  width: 120px;
  height: 30px;
  margin-top: 8px;
  float: left;
  width: 240px;
  max-height: 30px;
  margin-left: 8px;
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
  margin-right: 8px;
  & img {
    cursor: pointer;
  }
`;

// const LanguageSelect = styled.div`
//   display: inline-block;
// `;

export default compose(
  graphql(getUserQuery),
  withState('isOpen', 'onOpen', false),
  withHandlers({
    handleOpen: props => () => props.onOpen(true),
    closeMenu: props => () => props.onOpen(false),
    logout: props => () => {
      localStorage.removeItem('user_access_token');
      return window.location.reload();
    }
  })
)(Header);
