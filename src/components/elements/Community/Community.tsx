import React from 'react';
import styled from '../../../themes/styled';
import H5 from '../../typography/H5/H5';
import P from '../../typography/P/P';
import { Users, Collection } from '../Icons';
import Join from './Join';
import { Link } from 'react-router-dom';
import { clearFix } from 'polished';

interface Props {
  title: string;
  icon?: string;
  summary: string;
  id: string;
  followersCount: number;
  collectionsCount: number;
  followed: boolean;
  externalId: string;
}

const Community: React.SFC<Props> = ({
  title,
  id,
  icon,
  summary,
  followed,
  followersCount,
  collectionsCount,
  externalId
}) => (
  <Wrapper>
    <Link to={`/communities/${id}`}>
      <WrapperImage>
        <Img style={{ backgroundImage: `url(${icon})` }} />
        <Overlay />
      </WrapperImage>
      <H5>{title}</H5>
    </Link>
    <Actions>
      <Members>
        {followersCount}
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
    </Actions>

    <Summary>{summary}</Summary>
    <Infos>
      <Join externalId={externalId} followed={followed} id={id} />
    </Infos>
  </Wrapper>
);

export default Community;

const Actions = styled.div`
  ${clearFix()};
`;

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

const Members = styled(P)`
  color: #1e1f2480;
  margin: 8px 0;
  float: left;
  margin-right: 16px;
  & span {
    margin-left: 4px;
    display: inline-block;
    vertical-align: middle;
  }
`;

const Summary = styled(P)`
  margin: 0;
  font-size: 14px;
  color: rgba(0, 0, 0, 0.8);
  margin-bottom: 40px;
  word-break: break-all;
`;
const Wrapper = styled.div`
  border: 1px solid #e4e6e6;
  padding: 8px;
  border-radius: 3px;
  position: relative;
  max-height: 560px;
  & h5 {
    margin: 0;
    font-size: 18px !important;
    line-height: 24px !important;
    word-break: break-all;
  }
  & a {
    color: inherit;
    text-decoration: none;
    &:hover {
      text-decoration: underline;
    }
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
  background-color: rgba(250, 250, 250, 0.8);
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
const Infos = styled.div`
  border-top: 1px solid #e4e6e6;
  margin-top: 16px;
  position: absolute;
  bottom: 0;
  left: 0;
  background: white;
  right: 0;
  & p  {
    margin: 0;
    font-weight: 300;
    font-style: italic;
    display: inline-block;
    margin-right: 8px;
    font-size: 13px;
  }
`;
