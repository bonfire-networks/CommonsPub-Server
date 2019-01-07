import React from 'react';
import styled from '../../../themes/styled';
import H5 from '../../typography/H5/H5';
import P from '../../typography/P/P';
import { Link } from 'react-router-dom';

interface Props {
  title: string;
  icon?: string;
  id: string;
}

const Community: React.SFC<Props> = ({ title, id, icon }) => (
  <Wrapper>
    <WrapperImage>
      <Img style={{ backgroundImage: `url(${icon})` }} />
    </WrapperImage>
    <Link to={`communities/${id}`}>
      <H5>{title}</H5>
    </Link>
    <Infos>
      <P>12 Members</P>
      <P>5 Collection</P>
    </Infos>
  </Wrapper>
);

export default Community;

const Wrapper = styled.div`
  & h5 {
    margin: 0;
    font-size: 16px !important;
    line-height: 24px !important;
  }
  & a {
    color: inherit;
    text-decoration: none;
  }
`;
const WrapperImage = styled.div``;
const Img = styled.div`
  height: 200px;
  background-size: cover;
  background-position: center center;
  border-radius: 4px;
  background-repeat: no-repeat;
  margin-bottom: 8px;
  background-color: #f0eded;
`;
const Infos = styled.div`
  & p  {
    margin: 0;
    font-weight: 300;
    font-style: italic;
    display: inline-block;
    margin-right: 8px;
    font-size: 13px;
  }
`;
