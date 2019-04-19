import * as React from 'react';
import styled from '../../../themes/styled';
import { Reply } from '../../elements/Icons';
import { clearFix } from 'polished';

import moment from 'moment-timezone';
moment.tz.setDefault('UTC');

import Markdown from 'markdown-to-jsx';

import { Trans } from '@lingui/macro';
import Link from '../Link/Link';

interface EventProps {
  noAuthor?: boolean;
  author?: any;
  comment: {
    id: string;
    body: string;
    date: number;
  };
  thread?: boolean;
  totalReplies?: string;
  noAction?: boolean;
  selectThread(number): number;
}

const Event: React.SFC<EventProps> = ({
  author,
  thread,
  comment,
  noAction,
  totalReplies,
  selectThread,
  noAuthor
}) => {
  return (
    <FeedItem>
      {noAuthor ? null : (
        <Member>
          <MemberItem>
            <Img alt="user" src={author.icon} />
          </MemberItem>
          <MemberInfo>
            <h3>
              <Link to={'/user/' + author.localId}>{author.name}</Link>
            </h3>
            <Date>{moment(comment.date).fromNow()}</Date>
          </MemberInfo>
        </Member>
      )}
      <Desc>
        <Primary>
          <Markdown children={comment.body} />
        </Primary>
        {noAction ? null : (
          <Sub>
            <Actions>
              {thread ? null : (
                <Button onClick={() => selectThread(comment.id)}>
                  <Reply
                    width={16}
                    height={16}
                    strokeWidth={2}
                    color={'#667d99'}
                  />
                  <Trans>Reply</Trans> ({totalReplies})
                </Button>
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
  color: #667d99;
  font-weight: 500;
  font-size: 13px;
  cursor: pointer;
  &:hover {
    color: ${props => props.theme.styles.colour.primary};
    & svg {
      color: ${props => props.theme.styles.colour.primary};
    }
  }
  & svg {
    margin-right: 8px;
    vertical-align: sub;
  }
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
    font-size: 14px;
    margin: 0;
    color: ${props => props.theme.styles.colour.base3};
  }
`;

const Sub = styled.div`
  ${clearFix()};
  margin: 0px;
  margin-top: 8px;
`;

const MemberItem = styled.span`
  background-color: #d6dadc;
  border-radius: 50px;
  color: #4d4d4d;
  display: inline-block;
  height: 32px;
  overflow: hidden;
  position: relative;
  width: 32px;
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
  margin: 0;
  color: #667d99;
  margin-top: 2px;
  font-weight: 500;
`;

const Actions = styled.div`
  ${clearFix()};
  float: left;
  vertical-align: middle;
  & a {
    text-decoration: none;
  }
`;
