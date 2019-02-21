import { graphql, OperationOption } from 'react-apollo';
import { compose, withState } from 'recompose';
import Component from './Talk';
// const { getCommentsQuery } = require('../../../graphql/getThreads.graphql');
import { withFormik } from 'formik';
const {
  createThreadMutation
} = require('../../../graphql/createThread.graphql');
const { getCommunityQuery } = require('../../../graphql/getCommunity.graphql');

import * as Yup from 'yup';

interface FormValues {
  content: string;
}

interface MyFormProps {
  createThread: any;
  id: string;
  externalId: string;
  onToggle(boolean): boolean;
  toggle: boolean;
  setSubmitting(boolean): boolean;
  setFieldValue: any;
  isOpen: boolean;
  selectThread(number): number;
  onOpen(boolean): boolean;
}

const withCreateThread = graphql<{}>(createThreadMutation, {
  name: 'createThread'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const TalkWithFormik = withFormik<MyFormProps, FormValues>({
  mapPropsToValues: props => ({
    content: ''
  }),
  validationSchema: Yup.object().shape({
    content: Yup.string().required()
  }),
  handleSubmit: (values, { props, setSubmitting, setFieldValue }) => {
    const variables = {
      comment: {
        content: values.content
      },
      id: props.id
    };
    return props
      .createThread({
        variables: variables,
        update: (proxy, { data: { createThread } }) => {
          const data = proxy.readQuery({
            query: getCommunityQuery,
            variables: {
              context: props.id
            }
          });
          data.community.threads.edges.unshift({
            node: createThread,
            __typename: 'CommunityThreadsEdge'
          });
          proxy.writeQuery({
            query: getCommunityQuery,
            variables: {
              context: props.id
            },
            data: data.community
          });
        }
      })
      .then(res => {
        setSubmitting(false);
        setFieldValue('content', ' ');
        props.onOpen(false);
        props.onToggle(false);
      })
      .catch(err => console.log(err));
  }
})(Component);

export default compose(
  withCreateThread,
  withState('toggle', 'onToggle', false),
  withState('isOpen', 'onOpen', false)
)(TalkWithFormik);
