import * as React from 'react';
import styled from '../../../themes/styled';
import { Reply } from '../../elements/Icons';
import { clearFix } from 'polished';
import moment from 'moment';
import { NavLink } from 'react-router-dom';

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
}

const Event: React.SFC<EventProps> = ({ author, thread, comment }) => {
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
        <Primary>{comment.body}</Primary>
        <Sub>
          <Actions>
            {thread ? null : (
              <NavLink to={`/thread/${comment.id}`}>
                <Button>
                  <Reply
                    width={16}
                    height={16}
                    strokeWidth={2}
                    color={'#f0f0f0'}
                  />
                  Reply
                </Button>
              </NavLink>
            )}
          </Actions>
        </Sub>
      </Desc>
    </FeedItem>
  );
};

export default Event;

const Button = styled.div`
  background: #000000a6;
  padding: 0px 10px;
  border-radius: 3px;
  color: #f0f0f0;
  height: 30px;
  line-height: 30px;
  cursor: pointer;
  & svg {
    margin-right: 4px;
  }
`;

const FeedItem = styled.div<{ thread?: boolean }>`
  min-height: 30px;
  position: relative;
  margin: 0;
  padding: 8px;
  word-wrap: break-word;
  font-size: 14px;
  ${clearFix()};
  transition: background 0.5s ease;
  background: #eff0f0;
  border: 1px solid #e4e6e6;
  border-radius: ${props =>
    props.thread ? '3px 3px 0px 0px' : '0px 0px 3px 3px'};
`;

const Primary = styled.div`
  font-size: 16px;
  line-height: 24px;
  position: relative;
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
  margin-left: 0px;
  margin-top: 16px;

  & a {
    text-decoration: none;
  }
`;
