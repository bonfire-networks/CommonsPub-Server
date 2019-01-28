import React from 'react';
import styled from '../../../themes/styled';
import H5 from '../../typography/H5/H5';
// import P from '../../typography/P/P';
import { Link } from 'react-router-dom';
import { Preferites } from '../Icons';

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
        <Overlay>
          <Span>
            <Preferites
              width={32}
              height={32}
              strokeWidth={1}
              color={'#f0f0f0'}
            />
          </Span>
        </Overlay>
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

const Overlay = styled.span`
  position: absolute;
  background: rgba(0, 0, 0, 0.5);
  left: 0;
  right: 0;
  top: 0;
  bottom: 0;
  grid-template-columns: 1fr;
  grid-column-gap: 8px;
  display: none;
`;
const Span = styled.div`
  text-align: center;
  border-radius: 100px;
  width: 50px;
  height: 50px;
  text-align: center;
  cursor: pointer;
  margin: 0 auto;
  margin-top: 80px;
  & svg {
    margin-top: 8px;
    text-align: center;
  }
  &:hover  {
    background: rgba(0, 0, 0, 0.7);
  }
`;

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
const WrapperImage = styled.div`
  position: relative;
  &:hover {
    & span {
      display: grid;
    }
  }
`;
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
