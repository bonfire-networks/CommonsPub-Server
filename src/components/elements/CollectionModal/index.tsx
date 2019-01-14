import * as React from 'react';
import Modal from '../Modal';
import styled from '../../../themes/styled';
import { clearFix } from 'polished';
import H5 from '../../typography/H5/H5';
import Text from '../../inputs/Text/Text';
import Textarea from '../../inputs/TextArea/Textarea';
import Button from '../Button/Button';
import { compose } from 'react-apollo';
import { withFormik, FormikProps, Form, Field } from 'formik';
import * as Yup from 'yup';
import Alert from '../../elements/Alert';
import gql from 'graphql-tag';
import { graphql, OperationOption } from 'react-apollo';
const {
  createResourceMutation
} = require('../../../graphql/createResource.graphql');

interface Props {
  toggleModal?: any;
  modalIsOpen?: boolean;
  collectionId?: string;
  collectionExternalId?: string;
  errors: any;
  touched: any;
  isSubmitting: boolean;
}

interface FormValues {
  name: string;
  summary: string;
  image: string;
  url: string;
}

interface MyFormProps {
  collectionId: string;
  collectionExternalId: string;
  createResource: any;
  toggleModal: any;
}

const withCreateResource = graphql<{}>(createResourceMutation, {
  name: 'createResource'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const CreateCommunityModal = (props: Props & FormikProps<FormValues>) => {
  const { toggleModal, modalIsOpen, errors, touched, isSubmitting } = props;
  return (
    <Modal isOpen={modalIsOpen} toggleModal={toggleModal}>
      <Container>
        <Header>
          <H5>Add a new resource</H5>
        </Header>
        <Form>
          <Row>
            <label>Link</label>
            <ContainerForm>
              <Field
                name="url"
                render={({ field }) => (
                  <Text
                    placeholder="The url of the resource..."
                    name={field.name}
                    value={field.value}
                    onChange={field.onChange}
                  />
                )}
              />
              {errors.url && touched.url && <Alert>{errors.url}</Alert>}
            </ContainerForm>
          </Row>
          <Row>
            <label>Name</label>
            <ContainerForm>
              <Field
                name="name"
                render={({ field }) => (
                  <>
                    <Text
                      placeholder="The name of the resoruce..."
                      name={field.name}
                      value={field.value}
                      onChange={field.onChange}
                    />
                    <CounterChars>{80 - field.value.length}</CounterChars>
                  </>
                )}
              />
              {errors.name && touched.name && <Alert>{errors.name}</Alert>}
            </ContainerForm>
          </Row>
          <Row big>
            <label>Summary</label>
            <ContainerForm>
              <Field
                name="summary"
                render={({ field }) => (
                  <>
                    <Textarea
                      placeholder="What the resource is about..."
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
            <label>Image</label>
            <ContainerForm>
              <Field
                name="image"
                render={({ field }) => (
                  <Text
                    placeholder="Type a url of a background image..."
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
    url: '',
    name: '',
    summary: '',
    image: ''
  }),
  validationSchema: Yup.object().shape({
    url: Yup.string()
      .url()
      .required(),
    name: Yup.string()
      .max(80)
      .required(),
    summary: Yup.string().max(240),
    image: Yup.string().url()
  }),
  handleSubmit: (values, { props, setSubmitting }) => {
    const variables = {
      resourceId: Number(props.collectionId),
      resource: {
        name: values.name,
        summary: values.summary,
        icon: values.image,
        url: values.url
      }
    };
    return props
      .createResource({
        variables: variables,
        update: (proxy, { data: { createResource } }) => {
          const fragment = gql`
            fragment Res on Collection {
              id
              localId
              icon
              name
              content
              followersCount
              summary
              resources {
                id
                localId
                name
                summary
                url
                icon
              }
            }
          `;

          const collection = proxy.readFragment({
            id: `Collection:${props.collectionExternalId}`,
            fragment: fragment,
            fragmentName: 'Res'
          });
          console.log(createResource);
          collection.resources.unshift(createResource);
          console.log(collection);
          proxy.writeFragment({
            id: `Collection:${props.collectionExternalId}`,
            fragment: fragment,
            fragmentName: 'Res',
            data: collection
          });
          const collection2 = proxy.readFragment({
            id: `Collection:${props.collectionExternalId}`,
            fragment: fragment,
            fragmentName: 'Res'
          });
          console.log(collection2);
        }
      })
      .then(res => {
        setSubmitting(false);
        props.toggleModal();
      })
      .catch(err => console.log(err));
  }
})(CreateCommunityModal);

export default compose(withCreateResource)(ModalWithFormik);

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
