import * as React from 'react';
import Modal from '../Modal';
import styled from '../../../themes/styled';
import { clearFix } from 'polished';
import H5 from '../../typography/H5/H5';
import Text from '../../inputs/Text/Text';
import Button from '../Button/Button';
import { compose } from 'react-apollo';
import { withFormik, FormikProps, Form, Field } from 'formik';
import * as Yup from 'yup';
import Alert from '../../elements/Alert';
import { graphql, OperationOption } from 'react-apollo';
const { createUserMutation } = require('../../../graphql/createUser.graphql');
import { Trans } from '@lingui/macro';
import { i18nMark } from '@lingui/react';

const tt = {
  login: i18nMark('Sign in'),
  placeholders: {
    email: i18nMark('Enter your email'),
    name: i18nMark('Enter your name'),
    password: i18nMark('Enter your password'),
    passwordConfirm: i18nMark('Confirm your password')
  }
};

interface Props {
  toggleModal?: any;
  modalIsOpen?: boolean;
  errors: any;
  touched: any;
  isSubmitting: boolean;
}

interface FormValues {
  name: string;
  email: string;
  password: string;
  passwordConfirm: string;
}

interface MyFormProps {
  createUser: any;
  toggleModal: any;
}

const withCreateUser = graphql<{}>(createUserMutation, {
  name: 'createUser'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const CreateCommunityModal = (props: Props & FormikProps<FormValues>) => {
  const { toggleModal, modalIsOpen, errors, touched, isSubmitting } = props;
  return (
    <Modal isOpen={modalIsOpen} toggleModal={toggleModal}>
      <Container>
        <Header>
          <H5>
            <Trans>Create a new account</Trans>
          </H5>
        </Header>
        <Form>
          <Row>
            <label>
              <Trans>Email</Trans>
            </label>
            <ContainerForm>
              <Field
                name="email"
                render={({ field }) => (
                  <Text
                    placeholder={tt.placeholders.email}
                    name={field.name}
                    value={field.value}
                    onChange={field.onChange}
                  />
                )}
              />
              {errors.email && touched.email && <Alert>{errors.email}</Alert>}
            </ContainerForm>
          </Row>
          <Row>
            <label>
              <Trans>Username</Trans>
            </label>
            <ContainerForm>
              <Field
                name="name"
                render={({ field }) => (
                  <Text
                    placeholder={tt.placeholders.name}
                    name={field.name}
                    value={field.value}
                    onChange={field.onChange}
                  />
                )}
              />
            </ContainerForm>
          </Row>
          <Row>
            <label>
              <Trans>Password</Trans>
            </label>
            <ContainerForm>
              <Field
                name="password"
                render={({ field }) => (
                  <Text
                    placeholder={tt.placeholders.password}
                    type="password"
                    name={field.name}
                    value={field.value}
                    onChange={field.onChange}
                  />
                )}
              />
              {errors.password &&
                touched.password && <Alert>{errors.password}</Alert>}
            </ContainerForm>
          </Row>
          <Row>
            <label>
              <Trans>Confirm password</Trans>
            </label>
            <ContainerForm>
              <Field
                name="passwordConfirm"
                render={({ field }) => (
                  <Text
                    placeholder={tt.placeholders.passwordConfirm}
                    type="password"
                    name={field.name}
                    value={field.value}
                    onChange={field.onChange}
                  />
                )}
              />
              {errors.passwordConfirm &&
                touched.passwordConfirm && (
                  <Alert>{errors.passwordConfirm}</Alert>
                )}
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
    email: '',
    password: '',
    passwordConfirm: ''
  }),
  validationSchema: Yup.object().shape({
    name: Yup.string().required(),
    email: Yup.string()
      .email()
      .required(),
    password: Yup.string()
      .min(6)
      .required('Password is required'),
    passwordConfirm: Yup.string()
      .oneOf([Yup.ref('password'), null], 'Passwords must match')
      .required('Password confirm is required')
  }),
  handleSubmit: (values, { props, setSubmitting }) => {
    const variables = {
      user: {
        email: values.email,
        name: values.name,
        password: values.password,
        preferredUsername: values.name.split(' ').join('_')
      }
    };
    return props
      .createUser({
        variables: variables
      })
      .then(res => {
        localStorage.setItem('user_access_token', res.data.createUser.token);
        setSubmitting(false);
        window.location.reload();
      })
      .catch(err => console.log(err));
  }
})(CreateCommunityModal);

export default compose(withCreateUser)(ModalWithFormik);

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
  height: ${props => (props.big ? '180px' : '100px')};
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
  ${clearFix()};
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
