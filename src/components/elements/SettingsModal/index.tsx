import * as React from 'react';
import Modal from '../Modal';
import { Trans } from '@lingui/macro';
import H5 from '../../typography/H5/H5';
import Text from '../../inputs/Text/Text';
import Textarea from '../../inputs/TextArea/Textarea';
import Button from '../Button/Button';
import { compose } from 'react-apollo';
import { withFormik, FormikProps, Form, Field } from 'formik';
import * as Yup from 'yup';
import Alert from '../../elements/Alert';
import LanguageSelect from '../../inputs/LanguageSelect/LanguageSelect';
import { graphql, OperationOption } from 'react-apollo';
import User from '../../../types/User';
import {
  Row,
  Container,
  Actions,
  CounterChars,
  ContainerForm,
  Header
} from '../Modal/modal';

const {
  updateProfileMutation
} = require('../../../graphql/updateProfile.graphql');

interface Props {
  toggleModal?: any;
  modalIsOpen?: boolean;
  errors: any;
  touched: any;
  isSubmitting: boolean;
}

interface FormValues {
  name: string;
  summary: string;
  image: string;
}

interface MyFormProps {
  updateProfile: any;
  toggleModal: any;
  profile: User;
}

const withUpdateCommunity = graphql<{}>(updateProfileMutation, {
  name: 'updateProfile'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const CreateCommunityModal = (props: Props & FormikProps<FormValues>) => {
  const { toggleModal, modalIsOpen, errors, touched, isSubmitting } = props;
  return (
    <Modal isOpen={modalIsOpen} toggleModal={toggleModal}>
      <Container>
        <Header>
          <H5>
            <Trans>Update my profile &amp; settings</Trans>
          </H5>
        </Header>
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
              <Trans>Image</Trans>
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
          <Row>
            <label>
              <Trans>Primary Language</Trans>
            </label>
            <LanguageSelect />
          </Row>
          <Actions>
            <Button
              disabled={isSubmitting}
              type="submit"
              style={{ marginLeft: '10px' }}
            >
              <Trans>Save</Trans>
            </Button>
            <Button onClick={toggleModal} secondary>
              <Trans>Cancel</Trans>
            </Button>
          </Actions>
        </Form>
      </Container>
    </Modal>
  );
};

const ModalWithFormik = withFormik<MyFormProps, FormValues>({
  mapPropsToValues: props => ({
    name: props.profile.name || '',
    summary: props.profile.summary || '',
    image: props.profile.icon || ''
  }),
  validationSchema: Yup.object().shape({
    name: Yup.string().required(),
    summary: Yup.string(),
    image: Yup.string().url()
  }),
  handleSubmit: (values, { props, setSubmitting }) => {
    const variables = {
      profile: {
        name: values.name,
        preferredUsername: values.name,
        summary: values.summary,
        icon: values.image
      }
    };
    return props
      .updateProfile({
        variables: variables
      })
      .then(res => {
        setSubmitting(false);
        props.toggleModal();
      })
      .catch(err => console.log(err));
  }
})(CreateCommunityModal);

export default compose(withUpdateCommunity)(ModalWithFormik);
