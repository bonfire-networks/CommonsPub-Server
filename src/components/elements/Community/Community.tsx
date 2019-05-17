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
    <Link
      to={
        id
          ? `/communities/${id}`
          : `/communities/federate?url=${encodeURI(externalId)}`
      }
    >
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
    <SecondaryActions>
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
            <Message
              width={16}
              height={16}
              strokeWidth={2}
              color={'#1e1f2480'}
            />
          </span>
        </Members>
      </Actions>
      <Join externalId={externalId} followed={followed} id={id} />
    </SecondaryActions>
    <Summary>
      {summary.length > 160
        ? summary.replace(/^([\s\S]{156}[^\s]*)[\s\S]*/, '$1...')
        : summary}
    </Summary>
  </Wrapper>
);

export default Community;

const SecondaryActions = styled.div`
  position: relative;
  margin: 10px 0;
`;

const Actions = styled.div`
  ${clearFix()};
  display: inline-block;
  background: #686d81;
  border-radius: 20px;
  padding: 0 20px;
  text-align: center;
  border: 1px solid #282a364d;
  margin: 0 auto;
  p {
    line-height: 13px;
  }
  & p:last-of-type {
    margin-right: 0;
  }
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
  border-radius: 6px;
  overflow: hidden;
  z-index: 9;
  text-align: center;
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
    & h5 {
      margin-top: -6px:
    }
    p div {
      z-index: 0;
    }
  }
  & h5 {
    margin: 0;
    font-size: 14px !important;
    line-height: 20px !important;
    word-break: break-word;
    font-weight: 600;
    margin-bottom: 10px;
    margin-top: -6px;
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
