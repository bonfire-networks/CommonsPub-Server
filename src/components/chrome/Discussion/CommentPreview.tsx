import * as React from 'react';
import styled from '../../../themes/styled';
import { Message } from '../../elements/Icons';
import { clearFix } from 'polished';
import moment from 'moment';
import Link from '../../elements/Link/Link';
import removeMd from 'remove-markdown';

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
  type: string;
  selectThread(number): number;
  selectedThread: number;
  communityId: string;
}

const Event: React.SFC<EventProps> = ({
  author,
  comment,
  noAction,
  totalReplies,
  selectedThread,
  communityId,
  type
}) => {
  return (
    <LinkComment
      to={
        type === 'community'
          ? '/communities/' + communityId + '/thread/' + comment.id
          : '/collections/' + communityId + '/thread/' + comment.id
      }
    >
      <FeedItem active={selectedThread === Number(comment.id) ? true : false}>
        <Member>
          <MemberItem>
            <Img alt="user" src={author.icon} />
          </MemberItem>
          <MemberInfo>
            <h3>
              {author.name}
              <Button>
                <Message
                  width={16}
                  height={16}
                  strokeWidth={2}
                  color={'#3c3c3c'}
                />
                {totalReplies}
              </Button>
            </h3>
            <Primary>
              {comment.body.length > 320
                ? removeMd(comment.body).replace(
                    /^([\s\S]{316}[^\s]*)[\s\S]*/,
                    '$1...'
                  )
                : removeMd(comment.body)}
            </Primary>
          </MemberInfo>
        </Member>
        <Desc>
          {noAction ? null : (
            <Sub>
              <Actions>
                <Date>{moment(comment.date).fromNow()}</Date>
              </Actions>
            </Sub>
          )}
        </Desc>
      </FeedItem>
    </LinkComment>
  );
};

export default Event;

const LinkComment = styled(Link)`
  text-decoration: none;
`;

const Button = styled.div`
  color: #3c3c3c;
  cursor: pointer;
  font-weight: 600;
  margin-right: 8px;
  float: right;
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
  padding: 8px;
  margin: 8px;
  padding-bottom: 0px;
  word-wrap: break-word;
  font-size: 14px;
  border-radius: 6px;
  box-sizing: border-box;
  transition: background .2s;
  &:hover {
    background: #f3f6f9
  }
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
  margin-left: 40px;
  & h3 {
    font-size: 14px;
    margin: 0;
    color: ${props => props.theme.styles.colour.base2};
    text-decoration: none;
  }
`;

const Sub = styled.div`
  ${clearFix()};
  padding-left: 40px;
`;

const MemberItem = styled.span`
  background-color: #d6dadc;
  border-radius: 100px;
  color: #4d4d4d;
  float: left;
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
  margin-top: 8px;
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
  margin-top: -10px;
  color: #667d99;
  font-weight: 500;
`;

const Actions = styled.div`
  ${clearFix()};
`;
