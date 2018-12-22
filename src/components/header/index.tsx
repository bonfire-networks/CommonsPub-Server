import React from 'react';
import styled from '../../themes/styled';
import Text from '../inputs/Text/Text';
import { clearFix } from 'polished';
import Avatar from '../elements/Avatar/Avatar';

interface Props {}

const Header: React.SFC<Props> = props => (
  <Wrapper>
    <Left>
      <Text placeholder="Search" />
    </Left>
    <Right>
      <Avatar>
        <img src="https://picsum.photos/100/100?random" alt="Example avatar" />
      </Avatar>
    </Right>
  </Wrapper>
);

const Wrapper = styled.div`
  height: 50px;
  background: #fff;
  box-shadow: 0 2px 2px rgba(0, 0, 0, 0.1);
  ${clearFix()};
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
`;

export default Header;
