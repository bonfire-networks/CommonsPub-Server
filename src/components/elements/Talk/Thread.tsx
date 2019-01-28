import { graphql, OperationOption } from 'react-apollo';
import { compose, withState } from 'recompose';
import Component from './Talk';
const { getCommentsQuery } = require('../../../graphql/getThreads.graphql');
import { withFormik } from 'formik';
const {
  createThreadMutation
} = require('../../../graphql/createThread.graphql');

import * as Yup from 'yup';

interface FormValues {
  content: string;
}

interface MyFormProps {
  createThread: any;
  id: string;
  externalId: string;
  onToggle(): boolean;
  toggle: boolean;
  setSubmitting(boolean): boolean;
  setFieldValue: any;
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
    console.log(values);
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
            query: getCommentsQuery,
            variables: {
              id: props.id
            }
          });
          console.log(data.threads);
          data.threads.unshift(createThread);
          proxy.writeQuery({
            query: getCommentsQuery,
            variables: {
              id: props.id
            },
            data: data.threads
          });
        }
      })
      .then(res => {
        setSubmitting(false);
        setFieldValue('content', '');
      })
      .catch(err => console.log(err));
  }
})(Component);

export default compose(
  withCreateThread,
  withState('toggle', 'onToggle', false)
)(TalkWithFormik);
