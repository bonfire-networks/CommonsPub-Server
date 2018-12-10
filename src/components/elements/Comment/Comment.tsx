import * as React from 'react';
import ta from 'time-ago';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faComment, faHeart } from '@fortawesome/free-solid-svg-icons';

import styled from '../../../themes/styled';
import Avatar from '../Avatar/Avatar';
import User from '../../../types/User';
import { Link } from 'react-router-dom';

const CommentContainer = styled.div<any>`
  border-bottom: 1px solid ${props => props.theme.styles.colour.base4};
  margin-left: ${props => (props.child ? '50px' : '')};

  &:not(:first-child) {
    margin-top: 25px;
  }
`;

const CommentTop = styled.div`
  display: flex;
  flex-direction: row;
`;

const CommentBottom = styled.div`
  display: flex;
  justify-content: flex-end;
  padding: 10px;
`;

const AvatarContainer = styled.div`
  flex-grow: 1;
`;

const CommentBody = styled.div`
  padding: 0 10px 10px 10px;
  margin-right: 20px;
`;

const Metadata = styled.div`
  font-weight: bold;
  padding-bottom: 5px;
  padding-top: 5px;
`;

type Comment = {
  body: string;
  timestamp: number;
};

type CommentProps = {
  child?: boolean;
  author: User;
  comment: Comment;
  onHeartClicked?: Function;
  onCommentClicked?: Function;
};

/**
 * TODO turn comment timestamp into readable, e.g. X seconds ago
 * TODO handle comment author is active user so name comment author becomes "You"
 * @param [child] {Boolean} is the comment a child of another comment
 * @param author {User} author of the comment
 * @param comment {Object} comment data
 * @param [onCommentClicked] {Object} comment clicked callback
 * @param [onHeartClicked] {Object} comment "liked" callback
 */
export default function({
  author,
  comment,
  child = false,
  onCommentClicked = () => {},
  onHeartClicked = () => {}
}: CommentProps) {
  const origOnCommentClicked = onCommentClicked;
  const origOnHeartClicked = onHeartClicked;

  onCommentClicked = evt => {
    evt.preventDefault();
    origOnCommentClicked(evt);
  };

  onHeartClicked = evt => {
    evt.preventDefault();
    origOnHeartClicked(evt);
  };

  return (
    <CommentContainer child={child}>
      <CommentTop>
        <AvatarContainer>
          <Link to={'' /* TODO link to user profile */}>
            <Avatar size="large">
              <img alt={author.name} src={author.avatarImage} />
            </Avatar>
          </Link>
        </AvatarContainer>
        <CommentBody>
          <Metadata>
            {author.name}
            {' • '}
            {ta.ago(comment.timestamp)}
          </Metadata>
          <div>{comment.body}</div>
        </CommentBody>
      </CommentTop>
      <CommentBottom>
        <a href="#" onClick={onHeartClicked as any}>
          <FontAwesomeIcon icon={faHeart} />
        </a>
        <div style={{ width: '10px' }} />
        <a href="#" onClick={onCommentClicked as any}>
          <FontAwesomeIcon icon={faComment} />
        </a>
      </CommentBottom>
    </CommentContainer>
  );
}
