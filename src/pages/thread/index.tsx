import * as React from 'react';
import styled from '../../themes/styled';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
const getThread = require('../../graphql/getThread.graphql');
import CommentType from '../../types/Comment';
import { compose, withHandlers } from 'recompose';
import Loader from '../../components/elements/Loader/Loader';
import Comment from '../../components/elements/Comment/Comment';
import Talk from '../../components/elements/Talk/Reply';
import { Trans } from '@lingui/macro';
import Link from '../../components/elements/Link/Link';
import { Left } from '../../components/elements/Icons';
import { clearFix } from 'polished';
import { Helmet } from 'react-helmet';

interface Data extends GraphqlQueryControls {
  comment: CommentType;
}
interface Props {
  data: Data;
  id: string;
  match: any;
  history: any;
  type: string;
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
      id: Number(props.match.params.id)
    }
  })
}) as OperationOption<{}, {}>;

const Component = ({ data, id, selectThread, match, type, history }) => {
  if (data.error) {
    return 'error...';
  } else if (data.loading) {
    return <Loader />;
  }
  let author = {
    localId: data.comment.author.localId,
    name: data.comment.author.name,
    icon: data.comment.author.icon
  };

  let message = {
    body: data.comment.content,
    date: data.comment.published,
    id: data.comment.localId
  };
  return (
    <Container>
      <Helmet>
        <title>MoodleNet > Discussion Thread</title>
      </Helmet>
      <Wrapper>
        <Header>
          <Link
            to={
              data.comment.context.__typename === 'Community'
                ? `/communities/${data.comment.context.localId}`
                : `/collections/${data.comment.context.localId}`
            }
          >
            <LeftArr>
              <Left width={24} height={24} strokeWidth={2} color={'#68737d'} />
            </LeftArr>
          </Link>
        </Header>
      </Wrapper>
      <Wrapper>
        {data.comment.inReplyTo ? (
          <InReplyTo
            onClick={() => selectThread(data.comment.inReplyTo.localId)}
          >
            <Trans>Back to top-level thread</Trans>
          </InReplyTo>
        ) : null}
        <Comment
          selectThread={selectThread}
          noAction
          thread
          author={author}
          comment={message}
        />
        {data.comment.replies.edges.reverse().map((comment, i) => {
          let author = {
            localId: comment.node.author.localId,
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
              noAction
            />
          );
        })}
      </Wrapper>
      <WrapperTalk>
        <Talk id={Number(match.params.id)} externalId={data.comment.id} full />
      </WrapperTalk>
    </Container>
  );
};

const Container = styled.div`
  border-radius: 6px;
  box-sizing: border-box;
  border: 5px solid #e2e5ea;
`;

const Header = styled.div`
  border-bottom: 1px solid #edf0f2;
  ${clearFix()};
`;

const LeftArr = styled.span`
  display: inline-block;
  margin-bottom: 0;
  text-align: center;
  vertical-align: middle;
  cursor: pointer;
  white-space: nowrap;
  line-height: 20px;
  border-radius: 4px;
  user-select: none;
  color: #667d99;
  background-color: rgb(231, 237, 243);
  border: 0;
  width: 36px;
  text-align: center;
  padding: 5px;
  z-index: 3 !important;
  border-radius: 4px !important;
  transition: border-radius 0.2s;
  max-width: 150px;
  overflow: hidden;
  text-overflow: ellipsis;
  padding-left: 8px;
  padding-right: 8px;
  position: relative;
  background-color: #d7dfea;
  margin: 8px;
  margin-right: 0;
  float: left;
  & svg {
    vertical-align: middle;
  }
`;

const WrapperTalk = styled.div``;

const InReplyTo = styled.div`
  display: block;
  padding: 10px;
  text-align: center;
  background: #daecd6;
  color: #759053;
  font-size: 14px;
  font-weight: 600;
  text-decoration: none;
  cursor: pointer;
  &:hover {
    rgb(205, 222, 201);
  }
`;

const Wrapper = styled.div`
  background: white;
  & a {
    text-decoration: none;
  }
`;

export default compose(
  withGetThread,
  withHandlers({
    selectThread: props => link =>
      props.history.push(
        props.data.comment.context.__typename === 'Community'
          ? `/communities/${props.data.comment.context.localId}/thread/${link}`
          : `/collections/${props.data.comment.context.localId}/${link}`
      )
  })
)(Component);
