import * as React from 'react';
import { compose } from 'recompose';

import { Trans } from '@lingui/macro';
import { RouteComponentProps } from 'react-router';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import styled from '../../../themes/styled';
import Loader from '../../elements/Loader/Loader';
import Comment from '../../elements/Comment/Comment';
import Talk from '../../elements/Talk/Thread';

const { getCommentsQuery } = require('../../../graphql/getThreads.graphql');

interface Data extends GraphqlQueryControls {
  threads: any;
}

interface Props
  extends RouteComponentProps<{
      community: string;
    }> {
  data: Data;
  localId: string;
  id: string;
}

class CommunitiesFeatured extends React.Component<Props> {
  render() {
    let comments;
    if (this.props.data.loading) {
      comments = <Loader />;
    }
    if (this.props.data.error) {
      comments = (
        <span>
          <Trans>Error loading comments</Trans>
        </span>
      );
    } else if (this.props.data.threads) {
      comments = this.props.data.threads;

      if (this.props.data.threads) {
        comments = this.props.data.threads.map((comment, i) => {
          let author = {
            id: comment.author.id,
            name: comment.author.name,
            icon: comment.author.icon
          };
          let message = {
            body: comment.content,
            date: comment.published,
            id: comment.localId
          };
          return (
            <div key={i} style={{ marginBottom: '8px' }}>
              <Comment
                totalReplies={comment.replies.length}
                key={comment.id}
                author={author}
                comment={message}
              />
            </div>
          );
        });
      } else {
        comments = <OverviewCollection />;
      }
    }

    return (
      <>
        <Talk id={this.props.localId} externalId={this.props.id} />
        <WrapperComments>{comments}</WrapperComments>
      </>
    );
  }
}

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

const withGetComments = graphql<
  {},
  {
    data: {
      comments: any;
    };
  }
>(getCommentsQuery, {
  options: (props: Props) => ({
    variables: {
      id: parseInt(props.localId)
    }
  })
}) as OperationOption<{}, {}>;

export default compose(withGetComments)(CommunitiesFeatured);
