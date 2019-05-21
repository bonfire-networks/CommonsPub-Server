import React from 'react';
import styled from '../../../themes/styled';
import H5 from '../../typography/H5/H5';
import P from '../../typography/P/P';
import { Users, Collection, Message } from '../Icons';
// import Join from './Join';
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
      <WrapperImage>
        <Img
          style={{
            backgroundImage: `url(${icon || PlaceholderImg})`
          }}
        />
      </WrapperImage>
      <H5>
        {title.length > 60 ? title.replace(/^(.{56}[^\s]*).*/, '$1...') : title}
      </H5>

      <Summary>
        {summary.length > 160
          ? summary.replace(/^([\s\S]{156}[^\s]*)[\s\S]*/, '$1...')
          : summary}
      </Summary>
      <SecondaryActions>
        <Actions>
          <Members>
            {followersCount || 0}
            <span>
              <Users
                width={16}
                height={16}
                strokeWidth={2}
                color={'#1e1f2480'}
              />
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
        {/* <Join externalId={externalId} followed={followed} id={id} /> */}
      </SecondaryActions>
    </Link>
  </Wrapper>
);

export default Community;

const SecondaryActions = styled.div`
  position: relative;
`;

const Actions = styled.div`
  ${clearFix()};
  display: inline-block;
  text-align: center;
  margin: 0 auto;
  p {
    line-height: 13px;
    font-size: 12px;
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
  line-height: 20px;
  position: relative;
`;
const Wrapper = styled.div`
  padding: 10px;
  position: relative;
  max-height: 560px;
  overflow: hidden;
  z-index: 9;
  background-image: none;
  background-size: contain;
  background-position: center bottom;
  border-radius: 6px;
  padding-bottom: 0;
  &:hover {
    background: ${props => props.theme.styles.colour.newcommunityBgHover};
    text-decoration: none;
  }
  & h5 {
    margin: 0;
    font-size: 15px !important;
    line-height: 20px !important;
    word-break: break-word;
    font-weight: 500 !important;
    margin-bottom: 6px;
    margin-top: 0x;
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
  border-radius: 6px;
  background-repeat: no-repeat;
  margin-bottom: 8px;
  position: relative;
`;
