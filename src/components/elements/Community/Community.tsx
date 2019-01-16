import React from 'react';
import styled from '../../../themes/styled';
import H5 from '../../typography/H5/H5';
// import P from '../../typography/P/P';
import { Link } from 'react-router-dom';

interface Props {
  title: string;
  icon?: string;
  id: string;
  collectionsLength: number;
}

const Community: React.SFC<Props> = ({
  title,
  id,
  icon,
  collectionsLength
}) => (
  <Wrapper>
    <Link to={`communities/${id}`}>
      <WrapperImage>
        <Img style={{ backgroundImage: `url(${icon})` }} />
      </WrapperImage>
      <H5>{title}</H5>
    </Link>
    {/* <Infos>
      <P>12 <Trans>Members</Trans></P>
      <P>{collectionsLength} <Trans>Collection</Trans></P>
    </Infos> */}
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
  position: relative;
  &:before {
    position: absolute;
    content: '';
    left: 0;
    bottom: 0;
    right: 0;
    top: 0;
    display: block;
    background: transparent;
  }
  &:hover {
    &:before {
      background: rgba(0, 0, 0, 0.2);
    }
  }
`;
// const Infos = styled.div`
//   & p  {
//     margin: 0;
//     font-weight: 300;
//     font-style: italic;
//     display: inline-block;
//     margin-right: 8px;
//     font-size: 13px;
//   }
// `;
