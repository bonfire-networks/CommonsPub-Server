import { graphql, OperationOption } from 'react-apollo';
import { compose, withState } from 'recompose';
import Component from './Talk';
import gql from 'graphql-tag';
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
  handleSubmit: (values, { props, setSubmitting }) => {
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
          const fragment = gql`
            fragment Comm on Community {
              id
              comments {
                id
              }
            }
          `;
          const community = proxy.readFragment({
            id: `Community:${props.externalId}`,
            fragment: fragment,
            fragmentName: 'Comm'
          });
          console.log(community);
          community.comments.unshift(createThread);
          proxy.writeFragment({
            id: `Community:${props.externalId}`,
            fragment: fragment,
            fragmentName: 'Comm',
            data: community
          });
        }
      })
      .then(res => {
        setSubmitting(false);
      })
      .catch(err => console.log(err));
  }
})(Component);

export default compose(
  withCreateThread,
  withState('toggle', 'onToggle', false)
)(TalkWithFormik);
