import * as React from 'react';
import styled from '../../../themes/styled';
import Comment from '../../elements/Comment/Comment';
import Talk from '../../elements/Talk/Thread';

interface Props {
  threads: any;
  localId: string;
  id: string;
  followed?: boolean;
}

const CommunitiesFeatured: React.SFC<Props> = props => {
  return (
    <>
      {props.followed ? (
        <Talk id={props.localId} externalId={props.id} />
      ) : null}
      <WrapperComments>
        {props.threads ? (
          props.threads.edges.map((comment, i) => {
            let author = {
              id: comment.node.author.id,
              name: comment.node.author.name,
              icon: comment.node.author.icon
            };
            let message = {
              body: comment.node.content,
              date: comment.node.published,
              id: comment.node.localId
            };
            return (
              <div key={i} style={{ marginBottom: '8px' }}>
                <Comment
                  totalReplies={comment.node.replies.totalCount}
                  key={comment.node.id}
                  author={author}
                  comment={message}
                />
              </div>
            );
          })
        ) : (
          <OverviewCollection />
        )}
      </WrapperComments>
    </>
  );
};

const WrapperComments = styled.div`
  margin: 8px;
`;

const OverviewCollection = styled.div`
  padding: 0 8px;
  margin-bottom: 8px;
  & p {
    margin-top: 0 !important;
  }
`;

export default CommunitiesFeatured;
