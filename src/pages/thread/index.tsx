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
import { clearFix } from 'polished';
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
    icon: data.comment.author.icon
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
          <WrapperLink to={`/communities/${data.comment.context.localId}`}>
            <Context>
              <Img
                style={{ backgroundImage: `url(${data.comment.context.icon})` }}
              />
              <Title>{data.comment.context.name}</Title>
            </Context>
          </WrapperLink>
          {data.comment.inReplyTo ? (
            <NavLink to={`/thread/${data.comment.inReplyTo.localId}`}>
              <InReplyTo>
                <Trans>View full thread</Trans>
              </InReplyTo>
            </NavLink>
          ) : null}
          <Comment thread author={author} comment={message} />
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
              />
            );
          })}
        </Wrapper>
        <Talk id={match.params.id} externalId={data.comment.id} />
      </Grid>
    </Main>
  );
};

const WrapperLink = styled(NavLink)`
  background: white;
  display: block;
  &:hover {
    text-decoration: underline;
    background: #ececec40;
  }
`;

const Context = styled.div`
  font-size: 24px;
  color: ${props => props.theme.styles.colour.base1};
  font-weight: 700;
  padding: 16px;
  ${clearFix()};
`;

const Img = styled.div`
  float: left;
  width: 60px;
  height: 60px;
  border-radius: 3px;
  background-size: cover;
  background-color: #ececec;
`;

const Title = styled.div`
  float: left;
  height: 60px;
  line-height: 60px;
  margin-left: 8px;
  font-size: 20px;
  font-weight: 700;
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
  border: 1px solid #dddfe2;
  border-radius: 3px;
  background: white;
  & a {
    text-decoration: none;
  }
`;

export default compose(withGetThread)(Component);
