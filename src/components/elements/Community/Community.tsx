import React from 'react';
import styled from '../../../themes/styled';
import H5 from '../../typography/H5/H5';
import P from '../../typography/P/P';
import { Users, Collection, Message } from '../Icons';
import Join from './Join';
import { Link } from 'react-router-dom';
import { clearFix } from 'polished';
const PlaceholderImg = require('../Icons/communityPlaceholder.png');

interface Props {
  title: string;
  icon?: string;
  summary: string;
  id: string;
  followersCount: number;
  collectionsCount: number;
  followed: boolean;
  externalId: string;
  threadsCount: number;
}

const Community: React.SFC<Props> = ({
  title,
  id,
  icon,
  summary,
  followed,
  followersCount,
  collectionsCount,
  threadsCount,
  externalId
}) => (
  <Wrapper>
    <Link to={`/communities/${id}`}>
      <H5>
        {title.length > 60 ? title.replace(/^(.{56}[^\s]*).*/, '$1...') : title}
      </H5>
      <WrapperImage>
        <Img
          style={{
            backgroundImage: `url(${icon || PlaceholderImg})`
          }}
        />
      </WrapperImage>
    </Link>
    <Actions>
      <Members>
        {followersCount || 0}
        <span>
          <Users width={16} height={16} strokeWidth={2} color={'#1e1f2480'} />
        </span>
      </Members>
      <Members>
        {collectionsCount || 0}
        <span>
          <Collection
            width={16}
            height={16}
            strokeWidth={2}
            color={'#1e1f2480'}
          />
        </span>
      </Members>
      <Members>
        {threadsCount || 0}
        <span>
          <Message width={16} height={16} strokeWidth={2} color={'#1e1f2480'} />
        </span>
      </Members>
    </Actions>

    <Summary>
      {summary.length > 160
        ? summary.replace(/^([\s\S]{156}[^\s]*)[\s\S]*/, '$1...')
        : summary}
    </Summary>
    <Infos>
      <Join externalId={externalId} followed={followed} id={id} />
    </Infos>
  </Wrapper>
);

export default Community;

const Actions = styled.div`
  ${clearFix()};
`;

const Members = styled(P)`
  color: ${props => props.theme.styles.colour.communityIcon}
  margin: 8px 0;
  float: left;
  margin-right: 16px;
  & span {
    margin-left: 4px;
    display: inline-block;
    vertical-align: middle;
  }
  & svg {
    color: inherit !important;
  }
`;

const Summary = styled(P)`
  margin: 0;
  font-size: 14px;
  color: ${props => props.theme.styles.colour.communityNote};
  word-break: break-word;
  z-index: 99;
  position: relative;
`;
const Wrapper = styled.div`
  padding: 20px;
  position: relative;
  max-height: 560px;
  background: ${props => props.theme.styles.colour.communityBg};
  border-radius: 3px;
  overflow: hidden;
  z-index: 9;

  animation-delay: 0.5s;
  background-image: none;
  background-size: contain;
  background-position: center bottom;

  animation: 0.6s cubic-bezier(0.15, 1, 0.33, 1) 0s 1 normal forwards running
    fGLASt;
  box-shadow: rgba(23, 43, 77, 0.2) 0px 1px 1px,
    rgba(23, 43, 77, 0.25) 0px 0px 0.5px 0px;
  transition: all 0.3s cubic-bezier(0.15, 1, 0.33, 1) 0s;
  &:hover {
    transform: translateY(-2px);
    box-shadow: rgba(23, 43, 77, 0.32) 0px 4px 8px -2px,
      rgba(23, 43, 77, 0.25) 0px 0px 1px;
    text-decoration: none;
    color: rgb(9, 30, 66);
    & h5 {
      color: rgb(9, 30, 66);
    }
    p div {
      z-index: 0;
    }
    h6 {
      height: 45px;
      z-index: 9999;
      bottom: 0;
    }
  }
  & h5 {
    margin: 0;
    font-size: 14px !important;
    line-height: 20px !important;
    word-break: break-word;
    font-weight: 600;
    margin-bottom: 10px;
    color: ${props => props.theme.styles.colour.communityTitle};
  }
  & a {
    color: inherit;
    text-decoration: none;
    &:hover {
      text-decoration: none;
    }
  }
`;
const WrapperImage = styled.div`
  position: relative;
  margin: 0 -20px;
  &:hover {
    & span {
      display: block;
    }
  }
`;
const Img = styled.div`
  height: 200px;
  background-size: cover;
  background-position: center center;
  border-radius: 0px;
  background-repeat: no-repeat;
  margin-bottom: 8px;
  position: relative;
`;
const Infos = styled.h6`
  border-top: 1px solid #e4e6e6;
  position: absolute;
  bottom: 0;
  left: 0;
  background: white;
  right: 0;
  margin: 0;
  z-index: 0;
  bottom: -30px;
  background: #eaeef0;
  padding: 8px;
  transform: translate3d(0, 0, 0);
  transition: height 0.2s ease;
  transition: bottom 0.2s ease;
  height: 31px;
`;
