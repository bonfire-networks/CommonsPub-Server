// Add a resource to collection - step 2

import * as React from 'react';
import Textarea from '../../inputs/TextArea/Textarea';
import { withFormik, FormikProps, Form, Field } from 'formik';
import * as Yup from 'yup';
import styled from '../../../themes/styled';
import { Trans } from '@lingui/macro';
import { i18nMark } from '@lingui/react';
import Alert from '../Alert';
import { clearFix } from 'polished';
import Text from '../../inputs/Text/Text';
import Button from '../Button/Button';
import { LoaderButton } from '../Button/Button';
import ResourceCard from '../Resource/Resource';
import { compose } from 'recompose';
import gql from 'graphql-tag';
import { graphql, OperationOption } from 'react-apollo';
const {
  createResourceMutation
} = require('../../../graphql/createResource.graphql');

const withCreateResource = graphql<{}>(createResourceMutation, {
  name: 'createResource'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

interface Props {
  toggleModal?: any;
  modalIsOpen?: boolean;
  collectionId?: string;
  collectionExternalId?: string;
  errors: any;
  touched: any;
  isSubmitting: boolean;
  name: string;
  summary: string;
  image: string;
  onUrl(string): string;
  url: string;
  isFetched(boolean): boolean;
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
  name: string;
  summary: string;
  image: string;
  url: string;
  onUrl(string): string;
  isFetched(boolean): boolean;
}
const tt = {
  placeholders: {
    url: i18nMark('Enter the URL of the resource'),
    name: i18nMark('A name or title for the resource'),
    summary: i18nMark(
      'Please type or copy/paste a summary about the resource...'
    ),
    submit: i18nMark('Add'),
    image: i18nMark('Enter the URL of an image to represent the resource')
  }
};

const Fetched = (props: Props & FormikProps<FormValues>) => (
  <>
    <Preview>
      <ResourceCard
        icon={props.values.image}
        title={props.values.name}
        summary={props.values.summary}
        url={props.values.url}
        preview
      />
    </Preview>
    <Form>
      {/* <Row>
        <label>
          <Trans>Link</Trans>
        </label>
        <ContainerForm>
          <Field
            name="url"
            render={({ field }) => (
              <Text
                placeholder={tt.placeholders.url}
                name={field.name}
                value={field.value}
                onChange={field.onChange}
              />
            )}
          />
          {props.errors.url &&
            props.touched.url && <Alert>{props.errors.url}</Alert>}
        </ContainerForm>
      </Row> */}
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
                <CounterChars>{90 - field.value.length}</CounterChars>
              </>
            )}
          />
          {props.errors.name &&
            props.touched.name && <Alert>{props.errors.name}</Alert>}
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
                <CounterChars>{1000 - field.value.length}</CounterChars>
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
          {props.errors.image &&
            props.touched.image && <Alert>{props.errors.image}</Alert>}
        </ContainerForm>
      </Row>
      <Actions>
        <LoaderButton
          loading={props.isSubmitting}
          disabled={props.isSubmitting}
          text={tt.placeholders.submit}
          type="submit"
          style={{ marginLeft: '10px' }}
        />
        <Button onClick={props.toggleModal} secondary>
          <Trans>Cancel</Trans>
        </Button>
      </Actions>
    </Form>
  </>
);

const ModalWithFormik = withFormik<MyFormProps, FormValues>({
  mapPropsToValues: props => ({
    url: props.url || '',
    name: props.name || '',
    summary: props.summary || '',
    image: props.image || ''
  }),
  validationSchema: Yup.object().shape({
    url: Yup.string()
      .url()
      .required(),
    name: Yup.string()
      .max(90)
      .required(),
    summary: Yup.string().max(1000),
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
              summary
              resources {
                totalCount
                edges {
                  node {
                    id
                    localId
                    name
                    summary
                    url
                    icon
                  }
                }
              }
            }
          `;
          const collection = proxy.readFragment({
            id: `Collection:${props.collectionExternalId}`,
            fragment: fragment,
            fragmentName: 'Res'
          });
          collection.resources.edges.push({
            __typename: 'CollectionFollowersEdge',
            node: createResource
          });
          collection.resources.totalCount++;
          proxy.writeFragment({
            id: `Collection:${props.collectionExternalId}`,
            fragment: fragment,
            fragmentName: 'Res',
            data: collection
          });
        }
      })
      .then(res => {
        setSubmitting(false);
        props.isFetched(false);
        props.toggleModal();
        props.onUrl('');
        return;
      })
      .catch(err => console.log(err));
  }
})(Fetched);

export default compose(withCreateResource)(ModalWithFormik);

const Preview = styled.div`
  padding: 8px;
  background: #eff2f5;
  padding-bottom: 1px;
  border-bottom: 1px solid #eaeaea;
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

const Actions = styled.div`
  ${clearFix()};
  height: 60px;
  padding-top: 10px;
  padding-right: 10px;
  & button {
    float: right;
  }
`;
