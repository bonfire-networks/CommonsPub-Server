import React from 'react';
import styled from '../../themes/styled';
import Text from '../inputs/Text/Text';
import { clearFix } from 'polished';
import Avatar from '../elements/Avatar/Avatar';
import { compose, withHandlers, withState } from 'recompose';
interface Props {
  handleOpen(): boolean;
  isOpen: boolean;
}

const Header: React.SFC<Props> = props => (
  <Wrapper>
    <Left>
      <Text placeholder="Search" />
    </Left>
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
      <Menu>
        <List>
          <Item>Edit profile</Item>
          <Item>Settings</Item>
        </List>
        <List>
          <Item>Sign out</Item>
        </List>
      </Menu>
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

const Menu = styled.div`
  background: #fff;
  position: absolute;
  border-radius: 4px;
  top: 60px;
  width: 140px;
  right: 10px;
  box-shadow: 0 1px 1px rgba(0, 0, 0, 0.1);
`;
const List = styled.div`
  padding: 8px;
  border-bottom: 1px solid #dadada;
`;
const Item = styled.div`
  font-size: 14px;
  line-height: 30px;
  height: 30px;
  font-weight: 600;
  color: rgba(0, 0, 0, 0.6);
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
  margin-top: 5px;
  margin-right: 8px;
  & img {
    cursor: pointer;
  }
`;

export default compose(
  withState('isOpen', 'onOpen', false),
  withHandlers({
    handleOpen: props => props.onOpen(!props.isOpen)
  })
)(Header);
