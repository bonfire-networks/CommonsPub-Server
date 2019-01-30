import * as React from 'react';
import Modal from '../Modal';
import styled from '../../../themes/styled';

import { Trans } from '@lingui/macro';
import { i18nMark } from '@lingui/react';

const tt = {
  placeholders: {
    name: i18nMark('Choose a name for the collection'),
    summary: i18nMark(
      'Please describe what the collection is for and what kind of resources it is likely to contain...'
    ),
    image: i18nMark('Enter the URL of an image to represent the collection')
  }
};

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
  createCollectionMutation
} = require('../../../graphql/createCollection.graphql');

interface Props {
  toggleModal?: any;
  modalIsOpen?: boolean;
  communityId?: string;
  communityExternalId?: string;
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
  communityId: string;
  communityExternalId: string;
  createCollection: any;
  toggleModal: any;
}

const withCreateCollection = graphql<{}>(createCollectionMutation, {
  name: 'createCollection'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const CreateCommunityModal = (props: Props & FormikProps<FormValues>) => {
  const { toggleModal, modalIsOpen, errors, touched, isSubmitting } = props;
  return (
    <Modal isOpen={modalIsOpen} toggleModal={toggleModal}>
      <Container>
        <Header>
          <H5>
            <Trans>Create a new collection</Trans>
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
                      placeholder={tt.placeholders.name}
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
      .max(80)
      .required(),
    summary: Yup.string().max(240),
    image: Yup.string().url()
  }),
  handleSubmit: (values, { props, setSubmitting }) => {
    const variables = {
      communityId: Number(props.communityId),
      collection: {
        name: values.name,
        summary: values.summary,
        icon: values.image,
        content: values.summary,
        preferredUsername: values.name.split(' ').join('_')
      }
    };
    return props
      .createCollection({
        variables: variables,
        update: (store, { data }) => {
          const fragment = gql`
            fragment Coll on Collection {
              id
              collections {
                id
              }
            }
          `;
          const community = store.readFragment({
            id: `Community:${props.communityExternalId}`,
            fragment: fragment,
            fragmentName: 'Coll'
          });
          const newCommunity = {
            __typename: 'Collection',
            id: data.createCollection.id,
            localId: data.createCollection.localId,
            name: data.createCollection.name,
            summary: data.createCollection.summary,
            preferredUsername: data.createCollection.preferredUsername,
            icon: data.createCollection.icon,
            followed: data.createCollection.followed,
            followersCount: 0,
            followingCount: 0
          };

          community.collections.unshift(newCommunity);
          store.writeFragment({
            id: `Community:${props.communityExternalId}`,
            fragment: fragment,
            fragmentName: 'Coll',
            data: community
          });
        }
      })
      .then(res => {
        props.toggleModal();
        setSubmitting(false);
      })
      .catch(err => console.log(err));
  }
})(CreateCommunityModal);

export default compose(withCreateCollection)(ModalWithFormik);

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
