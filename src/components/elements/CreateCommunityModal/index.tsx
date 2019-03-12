import * as React from 'react';
import Modal from '../Modal';
import { withRouter } from 'react-router';
import { Trans } from '@lingui/macro';
import { i18nMark } from '@lingui/react';
import {
  Row,
  Container,
  Actions,
  CounterChars,
  ContainerForm,
  Header
} from '../Modal/modal';

const tt = {
  placeholders: {
    name: i18nMark('Choose a name for the community'),
    summary: i18nMark(
      'Please describe who might be interested in this community and what kind of collections it is likely to contain...'
    ),
    image: i18nMark('Enter the URL of an image to represent the community')
  }
};

import H5 from '../../typography/H5/H5';
import Text from '../../inputs/Text/Text';
import Textarea from '../../inputs/TextArea/Textarea';
import Button from '../Button/Button';
import { compose } from 'react-apollo';
import { withFormik, FormikProps, Form, Field } from 'formik';
import * as Yup from 'yup';
import Alert from '../../elements/Alert';
import { graphql, OperationOption } from 'react-apollo';
const {
  createCommunityMutation
} = require('../../../graphql/createCommunity.graphql');
interface Props {
  toggleModal?: any;
  modalIsOpen?: boolean;
  errors: any;
  touched: any;
  isSubmitting: boolean;
  setSubmitting(boolean): boolean;
  history: any;
}

interface FormValues {
  name: string;
  summary: string;
  image: string;
}

interface MyFormProps {
  createCommunity: any;
  toggleModal: any;
  setSubmitting(boolean): boolean;
  history: any;
}

const withCreateCommunity = graphql<{}>(createCommunityMutation, {
  name: 'createCommunity'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const CreateCommunityModal = (props: Props & FormikProps<FormValues>) => {
  const { toggleModal, modalIsOpen, errors, touched, isSubmitting } = props;
  return (
    <Modal isOpen={modalIsOpen} toggleModal={toggleModal}>
      <Container>
        <Header>
          <H5>
            <Trans>Create a new community</Trans>
          </H5>
        </Header>
        <Form>
          <Row>
            <label>Name</label>
            <ContainerForm>
              <Field
                name="name"
                render={({ field }) => (
                  <>
                    <Text
                      placeholder={tt.placeholders.name}
                      name={field.name}
                      value={field.value}
                      onChange={field.onChange}
                    />
                    <CounterChars>{60 - field.value.length}</CounterChars>
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
                      placeholder={tt.placeholders.summary}
                      name={field.name}
                      value={field.value}
                      onChange={field.onChange}
                    />
                    <CounterChars>{500 - field.value.length}</CounterChars>
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
                    placeholder={tt.placeholders.image}
                    name={field.name}
                    value={field.value}
                    onChange={field.onChange}
                  />
                )}
              />
              {errors.image && touched.image && <Alert>{errors.image}</Alert>}
            </ContainerForm>
          </Row>
          <Actions>
            <Button
              disabled={isSubmitting}
              type="submit"
              style={{ marginLeft: '10px' }}
            >
              <Trans>Create</Trans>
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
    name: '',
    summary: '',
    image: ''
  }),
  validationSchema: Yup.object().shape({
    name: Yup.string()
      .max(60)
      .required(),
    summary: Yup.string().max(500),
    image: Yup.string().url()
  }),
  handleSubmit: (values, { props, setSubmitting }) => {
    const variables = {
      community: {
        name: values.name,
        summary: values.summary,
        icon: values.image,
        content: values.summary,
        preferredUsername: values.name.split(' ').join('_')
      }
    };
    return props
      .createCommunity({
        variables: variables
      })
      .then(res => {
        setSubmitting(false);
        props.toggleModal();
        props.history.push(`/communities/${res.data.createCommunity.localId}`);
      })
      .catch(err => console.log(err));
  }
})(CreateCommunityModal);

export default compose(
  withCreateCommunity,
  withRouter
)(ModalWithFormik);
