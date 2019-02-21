import * as React from 'react';
import styled from '../../themes/styled';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
const getThread = require('../../graphql/getThread.graphql');
import CommentType from '../../types/Comment';
import { compose } from 'recompose';
import { RouteComponentProps } from 'react-router';
import Loader from '../../components/elements/Loader/Loader';
import Comment from '../../components/elements/Comment/Comment';
import Talk from '../../components/elements/Talk/Reply';
import { Trans } from '@lingui/macro';

interface Data extends GraphqlQueryControls {
  comment: CommentType;
}
interface Props
  extends RouteComponentProps<{
      id: string;
    }> {
  data: Data;
  id: number;
  selectThread(number): number;
}

const withGetThread = graphql<
  {},
  {
    data: {
      comment: CommentType;
    };
  }
>(getThread, {
  options: (props: Props) => ({
    variables: {
      id: Number(props.id)
    }
  })
}) as OperationOption<{}, {}>;

const Component = ({ data, id, selectThread }) => {
  if (data.error) {
    return 'error...';
  } else if (data.loading) {
    return <Loader />;
  }
  let author = {
    id: data.comment.author.id,
    name: data.comment.author.name,
    icon: data.comment.author.icon
  };

  let message = {
    body: data.comment.content,
    date: data.comment.published,
    id: data.comment.localId
  };
  return (
    <>
      <Wrapper>
        {data.comment.inReplyTo ? (
          <InReplyTo
            onClick={() => selectThread(data.comment.inReplyTo.localId)}
          >
            <Trans>View full thread</Trans>
          </InReplyTo>
        ) : null}
        <Comment
          selectThread={selectThread}
          noAction
          thread
          author={author}
          comment={message}
        />
        {data.comment.replies.edges.map((comment, i) => {
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
            <Comment
              key={i}
              author={author}
              totalReplies={comment.node.replies.totalCount}
              comment={message}
              selectThread={selectThread}
            />
          );
        })}
      </Wrapper>
      <WrapperTalk>
        <Talk id={id} externalId={data.comment.id} />
      </WrapperTalk>
    </>
  );
};

const WrapperTalk = styled.div`
  position: absolute;
  bottom: 40px;
  border-top: 1px solid #e9e7e7;
  left: 0;
  right: 0;
  z-index: 999999;
`;

const InReplyTo = styled.div`
  display: block;
  padding: 10px;
  text-align: center;
  background: #daecd6;
  color: #759053;
  font-size: 14px;
  font-weight: 600;
  text-decoration: none;
`;

const Wrapper = styled.div`
  background: white;
  padding-bottom: 49px;
  & a {
    text-decoration: none;
  }
`;

export default compose(withGetThread)(Component);
