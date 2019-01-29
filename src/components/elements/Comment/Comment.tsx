import * as React from 'react';
import styled from '../../../themes/styled';
import { Reply } from '../../elements/Icons';
import { clearFix } from 'polished';
import moment from 'moment';
import { NavLink } from 'react-router-dom';
import Markdown from 'markdown-to-jsx';

import { Trans } from '@lingui/macro';

interface EventProps {
  author: {
    id: string;
    name: string;
    image: string;
  };
  comment: {
    id: string;
    body: string;
    date: number;
  };
  thread?: boolean;
  totalReplies?: string;
  noAction?: boolean;
}

const Event: React.SFC<EventProps> = ({
  author,
  thread,
  comment,
  noAction,
  totalReplies
}) => {
  return (
    <FeedItem thread={thread}>
      <Member>
        <MemberItem>
          <Img alt="user" src={author.image} />
        </MemberItem>
        <MemberInfo>
          <h3>{author.name}</h3>
          <Date>{moment(comment.date).fromNow()}</Date>
        </MemberInfo>
      </Member>
      <Desc>
        <Primary>
          <Markdown children={comment.body} />
        </Primary>
        {noAction ? null : (
          <Sub>
            <Actions>
              {thread ? null : (
                <NavLink to={`/thread/${comment.id}`}>
                  <Button>
                    <Reply
                      width={16}
                      height={16}
                      strokeWidth={2}
                      color={'#1e1f2480'}
                    />
                    <Trans>Reply</Trans> ({totalReplies})
                  </Button>
                </NavLink>
              )}
            </Actions>
          </Sub>
        )}
      </Desc>
    </FeedItem>
  );
};

export default Event;

const Button = styled.div`
  padding: 0px 10px;
  color: #1e1f2480;
  height: 40px;
  font-weight: 600;
  line-height: 40px;
  cursor: pointer;
  &:hover {
    color: ${props => props.theme.styles.colour.primaryAlt};
    & svg {
      color: ${props => props.theme.styles.colour.primaryAlt};
    }
  }
  & svg {
    margin-right: 8px;
    vertical-align: sub;
  }
`;

const FeedItem = styled.div<{ thread?: boolean }>`
  min-height: 30px;
  position: relative;
  margin: 0;
  padding: 32px;
  padding-bottom: 0px;
  word-wrap: break-word;
  font-size: 14px;
  ${clearFix()};
  transition: background 0.5s ease;
  background: #fff;
  border: ${props =>
    props.thread ? '1px solid #0027ff' : '1px solid #e4e6e6'};
  margin-top: ${props => (props.thread ? '0' : '-1px')};
  z-index: 10;
  position: ${props => (props.thread ? 'relative' : 'static')};
`;

const Primary = styled.div`
  font-size: 15px;
  line-height: 24px;
  position: relative;
  letter-spacing: 0.5px;
  color: aqua;
  text-rendering: optimizeLegibility;
  -moz-font-feature-settings: 'liga' on;
  color: rgba(0, 0, 0, 0.84);
`;

const Member = styled.div`
  vertical-align: top;
  margin-right: 14px;
  ${clearFix()};
`;

const MemberInfo = styled.div`
  display: inline-block;
  & h3 {
    font-size: 13px;
    margin: 0;
    color: ${props => props.theme.styles.colour.base3};
    text-decoration: underline;
  }
`;

const Sub = styled.div`
  ${clearFix()};
  border-top: 1px solid #e4e6e6;
  margin: 16px -32px 0;
  padding: 0 32px;
`;

const MemberItem = styled.span`
  background-color: #d6dadc;
  border-radius: 3px;
  color: #4d4d4d;
  display: inline-block;
  height: 42px;
  overflow: hidden;
  position: relative;
  width: 42px;
  user-select: none;
  z-index: 0;
  vertical-align: inherit;
  margin-right: 8px;
`;

const Desc = styled.div`
  position: relative;
  min-height: 30px;
  margin-top: 16px;
`;

const Img = styled.img`
  width: 42px;
  height: 42px;
  display: block;
  -webkit-appearance: none;
  line-height: 42px;
  text-indent: 4px;
  font-size: 13px;
  overflow: hidden;
  max-width: 42px;
  max-height: 42px;
  text-overflow: ellipsis;
  vertical-align: text-top;
  margin-right: 8px;
`;

const Date = styled.div`
  font-size: 12px;
  line-height: 32px;
  height: 20px;
  margin: 0;
  color: ${props => props.theme.styles.colour.base2};
  margin-top: -4px;
  font-weight: 600;
`;

const Actions = styled.div`
  ${clearFix()};
  float: left;
  vertical-align: middle;
  & a {
    text-decoration: none;
  }
`;
