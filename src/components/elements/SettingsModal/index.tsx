import * as React from 'react';
import Modal from '../Modal';
import styled from '../../../themes/styled';

import { Trans } from '@lingui/macro';

import { clearFix } from 'polished';
import H5 from '../../typography/H5/H5';
import Text from '../../inputs/Text/Text';
import Textarea from '../../inputs/TextArea/Textarea';
import Button from '../Button/Button';
import { compose } from 'react-apollo';
import { withFormik, FormikProps, Form, Field } from 'formik';
import * as Yup from 'yup';
import Alert from '../../elements/Alert';
// import gql from 'graphql-tag';
import { graphql, OperationOption } from 'react-apollo';
import User from '../../../types/User';
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
            <Trans>Edit the profile</Trans>
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

const CounterChars = styled.div`
  float: right;
  font-size: 11px;
  text-transform: uppercase;
  background: #d0d9db;
  padding: 2px 10px;
  font-weight: 600;
  margin-top: 4px;
  color: #32302e;
  letter-spacing: 1px;
`;

const Container = styled.div`
  font-family: ${props => props.theme.styles.fontFamily};
`;
const Actions = styled.div`
  ${clearFix()};
  height: 60px;
  padding-top: 10px;
  padding-right: 10px;
  & button {
    float: right;
  }
`;

const Row = styled.div<{ big?: boolean }>`
  ${clearFix()};
  border-bottom: 1px solid rgba(151, 151, 151, 0.2);
  height: ${props => (props.big ? '180px' : 'auto')};
  display: flex;
  padding: 20px;
  & textarea {
    height: 120px;
  }
  & label {
    width: 200px;
    line-height: 40px;
  }
`;

const ContainerForm = styled.div`
  flex: 1;
`;

const Header = styled.div`
  height: 60px;
  border-bottom: 1px solid rgba(151, 151, 151, 0.2);
  & h5 {
    text-align: center !important;
    line-height: 60px !important;
    margin: 0 !important;
  }
`;
