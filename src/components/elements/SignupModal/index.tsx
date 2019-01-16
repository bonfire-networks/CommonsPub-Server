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
          <H5>Create a new account</H5>
        </Header>
        <Form>
          <Row>
            <label>Email</label>
            <ContainerForm>
              <Field
                name="email"
                render={({ field }) => (
                  <Text
                    placeholder="A valid email..."
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
            <label>Username</label>
            <ContainerForm>
              <Field
                name="name"
                render={({ field }) => (
                  <Text
                    placeholder="A choosed username..."
                    name={field.name}
                    value={field.value}
                    onChange={field.onChange}
                  />
                )}
              />
            </ContainerForm>
          </Row>
          <Row>
            <label>Password</label>
            <ContainerForm>
              <Field
                name="password"
                render={({ field }) => (
                  <Text
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
            <label>Confirm password</label>
            <ContainerForm>
              <Field
                name="passwordConfirm"
                render={({ field }) => (
                  <Text
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
              Create
            </Button>
            <Button onClick={toggleModal} secondary>
              Cancel
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
    password: Yup.string().required('Password is required'),
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
    console.log(variables);
    return props
      .createUser({
        variables: variables
      })
      .then(res => {
        console.log(res);
        localStorage.setItem('user_access_token', res.createUser.token);
        props.toggleModal();
        setSubmitting(false);
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
