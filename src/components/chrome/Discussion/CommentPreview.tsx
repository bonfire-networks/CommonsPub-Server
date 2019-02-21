import * as React from 'react';
import styled from '../../../themes/styled';
import { Reply } from '../../elements/Icons';
import { clearFix } from 'polished';
import moment from 'moment';
import Markdown from 'markdown-to-jsx';

interface EventProps {
  author: {
    id: string;
    name: string;
    icon: string;
  };
  comment: {
    id: string;
    body: string;
    date: number;
  };
  thread?: boolean;
  totalReplies?: string;
  noAction?: boolean;
  selectThread(number): number;
  selectedThread: number;
}

const Event: React.SFC<EventProps> = ({
  author,
  thread,
  comment,
  noAction,
  totalReplies,
  selectThread,
  selectedThread
}) => {
  return (
    <FeedItem
      active={selectedThread === Number(comment.id) ? true : false}
      onClick={() => selectThread(comment.id)}
    >
      <Member>
        <MemberItem>
          <Img alt="user" src={author.icon} />
        </MemberItem>
        <MemberInfo>
          <h3>{author.name}</h3>
          <Primary>
            <Markdown children={comment.body} />
          </Primary>
        </MemberInfo>
      </Member>
      <Desc>
        {noAction ? null : (
          <Sub>
            <Actions>
              <Date>{moment(comment.date).fromNow()}</Date>
              <Button>
                <Reply
                  width={16}
                  height={16}
                  strokeWidth={2}
                  color={'#1e1f2480'}
                />
                {totalReplies}
              </Button>
            </Actions>
          </Sub>
        )}
      </Desc>
    </FeedItem>
  );
};

export default Event;

const Button = styled.div`
  color: #1e1f2480;
  cursor: pointer;
  font-weight: 600;
  margin-left: 8px;
  float: left;
  & svg {
    margin-right: 8px;
    vertical-align: sub;
  }
`;

const FeedItem = styled.div<{ active?: boolean }>`
  min-height: 30px;
  position: relative;
  cursor: pointer;
  ${clearFix()};
  transition: background 0.5s ease;
  background: #fff;
  margin-top: 0:
  z-index: 10;
  margin: 8px;
    padding: 8px;
    padding-bottom: 0px;
    word-wrap: break-word;
    font-size: 14px;
    border-radius: 6px;
    box-shadow: 0 4px 20px rgba(0,0,0,.05);
    box-sizing: border-box;
    border: ${props => (props.active ? '3px solid #f98012' : '0px')}
`;

const Primary = styled.div`
  position: relative;
  text-rendering: optimizeLegibility;
  margin-top: 4px;
  font-size: 14px;
  line-height: 20px;
  color: rgba(0, 0, 0, 0.74);
`;

const Member = styled.div`
  vertical-align: top;
  ${clearFix()};
`;

const MemberInfo = styled.div`
  margin-left: 50px;
  & h3 {
    font-size: 13px;
    margin: 0;
    color: ${props => props.theme.styles.colour.base3};
    text-decoration: underline;
  }
`;

const Sub = styled.div`
  ${clearFix()};
  padding-left: 50px;
`;

const MemberItem = styled.span`
  background-color: #d6dadc;
  border-radius: 3px;
  color: #4d4d4d;
  float: left;
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
  margin-top: 8px;
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
  line-height: 25px;
  float: left;
  height: 20px;
  margin: 0;
  color: #1e1f2480;
  margin-top: -2px;
  font-weight: 600;
  margin-right: 10px;
`;

const Actions = styled.div`
  ${clearFix()};
`;
