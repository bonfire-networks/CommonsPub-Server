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

import { Trans } from '@lingui/macro';

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
  console.log(data);
  let author = {
    id: data.comment.author.id,
    name: data.comment.author.name,
    image: `https://www.gravatar.com/avatar/${
      data.comment.author.id
    }?f=y&d=identicon`
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
          <Context>
            <NavLink to={`/communities/${data.comment.context.localId}`}>
              #{data.comment.context.name}
            </NavLink>
          </Context>
          {data.comment.inReplyTo ? (
            <NavLink to={`/thread/${data.comment.inReplyTo.localId}`}>
              <InReplyTo>
                <Trans>View full thread</Trans>
              </InReplyTo>
            </NavLink>
          ) : null}
          <Comment thread author={author} comment={message} />
          {data.comment.replies.map((comment, i) => {
            let author = {
              id: comment.author.id,
              name: comment.author.name,
              image: 'https://picsum.photos/200/300'
            };
            let message = {
              body: comment.content,
              date: comment.published,
              id: comment.localId
            };
            return (
              <Comment
                key={i}
                author={author}
                totalReplies={comment.replies.length}
                comment={message}
              />
            );
          })}
        </Wrapper>
        <Talk id={match.params.id} externalId={data.comment.id} />
      </Grid>
    </Main>
  );
};

const Context = styled.div`
  font-size: 24px;
  color: ${props => props.theme.styles.colour.base1};
  font-weight: 700;
  margin-bottom: 16px;
  & a {
    color: inherit;
    &:hover {
      text-decoration: underline;
    }
  }
`;

const InReplyTo = styled.div`
  display: block;
  padding: 10px;
  text-align: center;
  background: #daecd6;
  border: 1px solid #bbc9d2;
  color: #759053;
  font-size: 14px;
  font-weight: 600;
  text-decoration: none;
`;

const Wrapper = styled.div`
  width: 720px;
  margin: 0 auto;
  margin-bottom: 8px;
  & a {
    text-decoration: none;
  }
`;

export default compose(withGetThread)(Component);
