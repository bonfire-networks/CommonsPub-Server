import * as React from 'react';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
import { Grid } from '@zendeskgarden/react-grid';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
const getThread = require('../../graphql/getThread.graphql');
import CommentType from '../../types/Comment';
import { compose } from 'recompose';
import { RouteComponentProps } from 'react-router';
import Loader from '../../components/elements/Loader/Loader';
import Comment from '../../components/elements/Comment/Comment';
import Talk from '../../components/elements/Talk/Reply';
import { NavLink } from 'react-router-dom';

interface Data extends GraphqlQueryControls {
  comment: CommentType;
}
interface Props
  extends RouteComponentProps<{
      id: string;
    }> {
  data: Data;
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

const Component = ({ data, match }) => {
  if (data.error) {
    return 'error...';
  } else if (data.loading) {
    return <Loader />;
  }
  // let author = {
  //     id: data.comment.author.id,
  //     name: data.comment.author.name,
  //     image: 'https://picsum.photos/200/300'
  // };
  let author = {
    id: 'comment.author.id',
    name: 'Chet Faker',
    image: 'https://picsum.photos/200/300'
  };
  let message = {
    body: data.comment.content,
    date: data.comment.published,
    id: data.comment.localId
  };
  return (
    <Main>
      <Grid>
        <Wrapper>
          {data.comment.inReplyTo ? (
            <NavLink to={`/thread/${data.comment.inReplyTo.id}`}>
              <InReplyTo>View full thread</InReplyTo>
            </NavLink>
          ) : null}
          <Comment thread author={author} comment={message} />
          {data.comment.replies.map((comment, i) => {
            let author = {
              id: 'comment.author.id',
              name: 'Chet Faker',
              image: 'https://picsum.photos/200/300'
            };
            // let author = {
            //     id: comment.author.id,
            //     name: comment.author.name,
            //     image: 'https://picsum.photos/200/300'
            // };
            let message = {
              body: comment.content,
              date: comment.published,
              id: comment.localId
            };
            return <Comment key={i} author={author} comment={message} />;
          })}
        </Wrapper>
        <Talk id={match.params.id} externalId={data.comment.id} />
      </Grid>
    </Main>
  );
};

const InReplyTo = styled.div`
  display: block;
  padding: 10px;
  text-align: center;
  background: #daecd6;
  border-top: 1px solid #bbc9d2;
  border-bottom: 1px solid #bbc9d2;
  color: #759053;
`;

const Wrapper = styled.div`
  width: 720px;
  margin: 0 auto;
  margin-bottom: 8px;
`;

export default compose(withGetThread)(Component);
