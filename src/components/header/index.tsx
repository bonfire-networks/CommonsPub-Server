import React from 'react';
import styled from '../../themes/styled';
// import Text from '../inputs/Text/Text';
import { clearFix } from 'polished';
import { compose, withHandlers, withState } from 'recompose';
interface Props {
  handleOpen(): boolean;
  isOpen: boolean;
  logout(): any;
  history: any;
}

const Header: React.SFC<Props> = props => (
  <Wrapper>
    {/* <Left>
      <Text placeholder="Search" />
    </Left> */}
    <Right>
      <Avatar>
        <img
          onClick={props.handleOpen}
          src="https://picsum.photos/100/100?random"
          alt="Example avatar"
        />
      </Avatar>
    </Right>
    {props.isOpen ? (
      <WrapperMenu>
        <Menu>
          <List lined>
            <Item>Ivan Minutillo</Item>
            <Item>Edit profile</Item>
            <Item>Settings</Item>
          </List>
          <List>
            <Item onClick={props.logout}>Sign out</Item>
          </List>
        </Menu>
      </WrapperMenu>
    ) : null}
  </Wrapper>
);

const Wrapper = styled.div`
  height: 50px;
  background: #fff;
  box-shadow: 0 1px 1px rgba(0, 0, 0, 0.1);
  ${clearFix()};
  position: relative;
`;

const Avatar = styled.div`
  width: 32px;
  height: 32px;
  border-radius: 100px;
  overflow: hidden;
`;

const WrapperMenu = styled.div`
  box-sizing: border-box;
  width: 20em;
  padding: 5px;
  border-radius: 0.25em;
  background-color: rgb(232, 232, 232);
  position: absolute;
  top: 60px;
  right: 10px;
  z-index: 9999;
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
// const Left = styled.div`
//   float: left;
//   width: 120px;
//   height: 30px;
//   margin-top: 8px;
//   float: left;
//   width: 240px;
//   max-height: 30px;
//   margin-left: 8px;
//   & input {
//     border: 0px solid !important;
//     border-radius: 100px;
//     height: 34px;
//     max-height: 34px;
//     min-height: 34px;
//     background: #f6f6f6;
//   }
// `;
const Right = styled.div`
  float: right;
  margin-top: 9px;
  margin-right: 8px;
  & img {
    cursor: pointer;
  }
`;

export default compose(
  withState('isOpen', 'onOpen', false),
  withHandlers({
    handleOpen: props => () => props.onOpen(!props.isOpen),
    logout: props => () => {
      console.log(props.history);
      localStorage.removeItem('user_access_token');
      return window.location.reload();
    }
  })
)(Header);
