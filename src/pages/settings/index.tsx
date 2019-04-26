import * as React from 'react';
import styled from '../../themes/styled';
import { graphql, OperationOption } from 'react-apollo';
const getSettings = require('../../graphql/meThread.graphql');
import CommentType from '../../types/Comment';
import { compose } from 'recompose';
import Loader from '../../components/elements/Loader/Loader';
// import { Trans } from '@lingui/macro';

// import { clearFix } from 'polished';
import { Helmet } from 'react-helmet';

interface Props {
  data: any;
  id: string;
  match: any;
  history: any;
  type: string;
  selectThread(number): number;
}

const withGetSettings = graphql<
  {},
  {
    data: {
      comment: CommentType;
    };
  }
>(getSettings) as OperationOption<{}, {}>;

const Component = ({ data, id, selectThread, match, type, history }: Props) => {
  if (data.error) {
    return 'error...';
  } else if (data.loading) {
    return <Loader />;
  }
  return (
    <Container>
      <Helmet>
        <title>MoodleNet > Settings</title>
      </Helmet>
    </Container>
  );
};

const Container = styled.div`
  border-radius: 6px;
  box-sizing: border-box;
  border: 5px solid #e2e5ea;
`;

export default compose(
  withGetSettings
  //   withHandlers({
  //     selectThread: props => link =>
  //       props.history.push(
  //         props.data.comment.context.__typename === 'Community'
  //           ? `/communities/${props.data.comment.context.localId}/thread/${link}`
  //           : `/collections/${props.data.comment.context.localId}/${link}`
  //       )
  //   })
)(Component);
