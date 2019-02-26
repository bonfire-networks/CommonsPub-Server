import { graphql, OperationOption } from 'react-apollo';
import { compose, withState } from 'recompose';
import Component from './Talk';
import { withFormik } from 'formik';
import gql from 'graphql-tag';

const { createReplyMutation } = require('../../../graphql/createReply.graphql');

import * as Yup from 'yup';

interface FormValues {
  content: string;
}

interface MyFormProps {
  createThread: any;
  externalId: string;
  id: string;
  onToggle(boolean): boolean;
  onOpen(boolean): boolean;
  isOpen: boolean;
  toggle: boolean;
  full: boolean;
  setSubmitting(boolean): boolean;
}

const withCreateThread = graphql<{}>(createReplyMutation, {
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
      id: Number(props.id)
    };
    return props
      .createThread({
        variables: variables,
        update: (proxy, { data: { createReply } }) => {
          const fragment = gql`
            fragment Comm on Comment {
              id
              replies {
                edges {
                  node {
                    id
                    localId
                    content
                    published
                  }
                }
              }
            }
          `;
          const comment = proxy.readFragment({
            id: `Comment:${props.externalId}`,
            fragment: fragment,
            fragmentName: 'Comm'
          });
          comment.replies.edges.push({
            node: createReply,
            __typename: 'CollectionRepliesEdge'
          });
          proxy.writeFragment({
            id: `Comment:${props.externalId}`,
            fragment: fragment,
            fragmentName: 'Comm',
            data: comment
          });
        }
      })
      .then(res => {
        setSubmitting(false);
        setFieldValue('content', '');
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
