import * as React from 'react';
import { graphql, OperationOption } from 'react-apollo';
import { compose } from 'recompose';
import { Trans } from '@lingui/macro';
import { withFormik, FormikProps, Form, Field } from 'formik';
import * as Yup from 'yup';
import Alert from '../../components/elements/Alert';
import Text from '../../components/inputs/Text/Text';
import Textarea from '../../components/inputs/TextArea/Textarea';
import Button from '../../components/elements/Button/Button';
// import { clearFix } from 'polished';
// import User from '../../types/User';
const {
  updateProfileMutation
} = require('../../graphql/updateProfile.graphql');

import {
  Row,
  Actions,
  CounterChars,
  ContainerForm
} from '../../components/elements/Modal/modal';

const withUpdateCommunity = graphql<{}>(updateProfileMutation, {
  name: 'updateProfile'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

interface Props {
  errors: any;
  touched: any;
  isSubmitting: boolean;
  profile: any;
}

interface FormValues {
  name: string;
  summary: string;
  image: string;
  username: string;
  location: string;
}

interface MyFormProps {
  updateProfile: any;
  profile: any;
}

const Component = (props: Props & FormikProps<FormValues>) => {
  const { errors, touched, isSubmitting } = props;
  return (
    <Form>
      <Row>
        <label>
          <Trans>Name</Trans>
        </label>
        <ContainerForm>
          <Field
            name="name"
            render={({ field }) => (
              <>
                <Text
                  // placeholder="The name of the community..."
                  name={field.name}
                  value={field.value}
                  onChange={field.onChange}
                />
              </>
            )}
          />
          {errors.name && touched.name && <Alert>{errors.name}</Alert>}
        </ContainerForm>
      </Row>
      {/* <Row>
        <label>
          <Trans>Preferred username</Trans>
        </label>
        <ContainerForm>
          <Field
            name="username"
            render={({ field }) => (
              <>
                <Text
                  // placeholder="The name of the community..."
                  name={field.name}
                  value={field.value}
                  onChange={field.onChange}
                />
              </>
            )}
          />
          {errors.username &&
            touched.username && <Alert>{errors.username}</Alert>}
        </ContainerForm>
      </Row> */}
      <Row>
        <label>
          <Trans>Location</Trans>
        </label>
        <ContainerForm>
          <Field
            name="location"
            render={({ field }) => (
              <>
                <Text
                  // placeholder="The name of the community..."
                  name={field.name}
                  value={field.value}
                  onChange={field.onChange}
                />
              </>
            )}
          />
          {errors.location &&
            touched.location && <Alert>{errors.location}</Alert>}
        </ContainerForm>
      </Row>
      <Row big>
        <label>
          <Trans>Description</Trans>
        </label>
        <ContainerForm>
          <Field
            name="summary"
            render={({ field }) => (
              <>
                <Textarea
                  // placeholder="What the community is about..."
                  name={field.name}
                  value={field.value}
                  onChange={field.onChange}
                />
                <CounterChars>{240 - field.value.length}</CounterChars>
              </>
            )}
          />
        </ContainerForm>
      </Row>
      <Row>
        <label>
          <Trans>Avatar</Trans>
        </label>
        <ContainerForm>
          <Field
            name="image"
            render={({ field }) => (
              <Text
                // placeholder="Type a url of a background image..."
                name={field.name}
                value={field.value}
                onChange={field.onChange}
              />
            )}
          />
          {errors.image && touched.image && <Alert>{errors.image}</Alert>}
        </ContainerForm>
      </Row>
      {/* <Row>
        <label>
          <Trans>Header image</Trans>
        </label>
        <ContainerForm>
          <Field
            name="header"
            render={({ field }) => (
              <Text
                // placeholder="Type a url of a background image..."
                name={field.name}
                value={field.value}
                onChange={field.onChange}
              />
            )}
          />
          {errors.header && touched.header && <Alert>{errors.header}</Alert>}
        </ContainerForm>
      </Row> */}
      {/* <Row>
            <label>
              <Trans>Primary Language</Trans>
            </label>
            <LanguageSelect />
          </Row> */}
      <Actions>
        <Button
          disabled={isSubmitting}
          type="submit"
          style={{ marginLeft: '10px' }}
        >
          <Trans>Save</Trans>
        </Button>
      </Actions>
    </Form>
  );
};

const ModalWithFormik = withFormik<MyFormProps, FormValues>({
  mapPropsToValues: props => ({
    name: props.profile.user.name || '',
    summary: props.profile.user.summary || '',
    location: props.profile.user.location || '',
    image: props.profile.user.icon || '',
    username: props.profile.user.preferredUsername || ''
  }),
  validationSchema: Yup.object().shape({
    name: Yup.string().required(),
    summary: Yup.string(),
    image: Yup.string().url(),
    username: Yup.string(),
    location: Yup.string()
  }),
  handleSubmit: (values, { props, setSubmitting }) => {
    const variables = {
      profile: {
        name: values.name,
        preferredUsername: values.username,
        summary: values.summary,
        location: values.location,
        icon: values.image
      }
    };
    return props
      .updateProfile({
        variables: variables
      })
      .then(res => {
        setSubmitting(false);
      })
      .catch(err => console.log(err));
  }
})(Component);

export default compose(withUpdateCommunity)(ModalWithFormik);
