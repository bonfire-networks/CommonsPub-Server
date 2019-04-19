import Link from '../Link/Link';
import styled from '../../../themes/styled';
import * as React from 'react';
import { SFC } from 'react';
import { clearFix } from 'polished';
import { Trans } from '@lingui/react';
import removeMd from 'remove-markdown';

import moment from 'moment-timezone';
moment.tz.setDefault('UTC');

interface Props {
  userpage?: boolean;
  user: any;
  node: any;
}

const Item: SFC<Props> = ({ user, node, userpage }) => (
  <FeedItem>
    <Member>
      <MemberItem>
        <Img src={user.icon} />
      </MemberItem>
      <FeedItemContents>
        {userpage ? (
          <b>{user.name}</b>
        ) : (
          <Link to={'/user/' + user.localId}>
            <Name>{user.name}</Name>
          </Link>
        )}

        {node.activityType === 'CreateCollection' ? (
          <span>
            <Trans>created the collection</Trans>{' '}
            <Link to={`/collections/` + node.object.localId}>
              {node.object.name}
            </Link>{' '}
          </span>
        ) : node.activityType === 'UpdateCommunity' ? (
          <span>
            <Trans>updated the community</Trans>{' '}
            <Link to={`/communities/${node.object.localId}`}>
              {node.object.name}
            </Link>
          </span>
        ) : node.activityType === 'UpdateCollection' ? (
          <span>
            <Trans>updated the collection</Trans>{' '}
            <Link to={`/collections/` + node.object.localId}>
              {node.object.name}
            </Link>
          </span>
        ) : node.activityType === 'JoinCommunity' ? (
          <span>
            <Trans>joined the community</Trans>{' '}
            <Link to={`/communities/${node.object.localId}`}>
              {node.object.name}
            </Link>
          </span>
        ) : node.activityType === 'CreateComment' ? (
          <span>
            {node.object.inReplyTo !== null ? (
              <Trans>replied to</Trans>
            ) : (
              <Trans>started</Trans>
            )}{' '}
            <Link
              to={
                node.object.context.__typename === 'Community'
                  ? `/communities/${node.object.context.localId}/thread/${
                      node.object.localId
                    }`
                  : `/collections/${node.object.context.localId}/thread/${
                      node.object.localId
                    }`
              }
            >
              <Trans>a discussion</Trans>
            </Link>{' '}
            <Trans>in the</Trans>{' '}
            {node.object.context.__typename === 'Community' ? (
              <Trans>community</Trans>
            ) : (
              <Trans>collection</Trans>
            )}{' '}
            <Link
              to={
                node.object.context.__typename === 'Community'
                  ? `/communities/${node.object.context.localId}`
                  : `/collections/${node.object.context.localId}`
              }
            >
              {node.object.context.name}
            </Link>
            :
            <Comment>
              <Link
                to={
                  node.object.context.__typename === 'Community'
                    ? `/communities/${node.object.context.localId}/thread/${
                        node.object.localId
                      }`
                    : `/collections/${node.object.context.localId}/thread/${
                        node.object.localId
                      }`
                }
              >
                {node.object.content && node.object.content.length > 320
                  ? removeMd(node.object.content).replace(
                      /^([\s\S]{316}[^\s]*)[\s\S]*/,
                      '$1...'
                    )
                  : removeMd(node.object.content)}
              </Link>
            </Comment>
          </span>
        ) : node.activityType === 'CreateResource' ? (
          <span>
            <Trans>added the resource</Trans> <b>{node.object.name}</b>{' '}
            <Trans>in the collection</Trans>{' '}
            <Link to={`/collections/` + node.object.collection.localId}>
              {node.object.collection.name}
            </Link>{' '}
          </span>
        ) : node.activityType === 'FollowCollection' ? (
          <span>
            <Trans>is following the collection</Trans>{' '}
            <Link to={`/collections/` + node.object.localId}>
              {node.object.name}
            </Link>
          </span>
        ) : null}
        <Date>{moment(node.published).fromNow()}</Date>
      </FeedItemContents>
    </Member>
  </FeedItem>
);
const Name = styled.span`
  font-weight: 600;
  color: ${props => props.theme.styles.colour.base2};
  &:hover {
    text-decoration: underline;
  }
`;

const Member = styled.div`
  vertical-align: top;
  margin-right: 14px;
  ${clearFix()};
`;

const FeedItemContents = styled.div`
  margin-left: 40px;
  font-size: 14px;
  margin: 0;
  color: ${props => props.theme.styles.colour.base2};
  font-weight: 400;
  & span {
    margin-right: 3px;
  }
  & a {
    text-decoration: none;
    font-weight: 500;
  }
`;

const Comment = styled.div`
  margin-top: 6px;
  & a {
    color: ${props => props.theme.styles.colour.base2} !important;
    font-weight: 400 !important;
  }
`;

const MemberItem = styled.span`
  background-color: #d6dadc;
  border-radius: 50px;
  height: 32px;
  overflow: hidden;
  position: relative;
  width: 32px;
  user-select: none;
  z-index: 0;
  vertical-align: inherit;
  margin-right: 8px;
  float: left;
`;

const Img = styled.img`
  width: 32px;
  height: 32px;
  display: block;
  -webkit-appearance: none;
  line-height: 32px;
  text-indent: 4px;
  font-size: 13px;
  overflow: hidden;
  max-width: 32px;
  max-height: 32px;
  text-overflow: ellipsis;
  vertical-align: text-top;
  margin-right: 8px;
`;

const Date = styled.div`
  font-size: 12px;
  line-height: 32px;
  height: 20px;
  margin: 0;
  color: ${props => props.theme.styles.colour.base4};
  margin-top: 0px;
  font-weight: 500;
  float: right;
`;

const FeedItem = styled.div`
  min-height: 30px;
  position: relative;
  margin: 0;
  padding: 16px;
  word-wrap: break-word;
  font-size: 14px;
  ${clearFix()};
  transition: background 0.5s ease;
  background: #fff;
  margin-top: 0
  z-index: 10;
  position: relative;
  border-bottom: 1px solid #eaeaea;
`;

export default Item;
