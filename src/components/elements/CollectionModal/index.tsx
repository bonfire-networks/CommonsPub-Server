import * as React from 'react';
import Modal from '../Modal';
import styled from '../../../themes/styled';
import { Trans } from '@lingui/macro';
import { Search } from '../Icons';
import Loader from '../Loader/Loader';
import { i18nMark } from '@lingui/react';
import Fetched from './fetched';
const tt = {
  placeholders: {
    url: i18nMark('Enter the URL of the resource'),
    name: i18nMark('A name or title for the resource'),
    summary: i18nMark(
      'Please type or copy/paste a summary about the resource...'
    ),
    submit: i18nMark('Fetch the resource'),
    image: i18nMark('Enter the URL of an image to represent the resource')
  }
};

import { clearFix } from 'polished';
import H5 from '../../typography/H5/H5';
import Text from '../../inputs/Text/Text';
// import { LoaderButton } from '../Button/Button';
import { compose, withState } from 'recompose';
import { withFormik, FormikProps, Form, Field } from 'formik';
import * as Yup from 'yup';
import { graphql, OperationOption } from 'react-apollo';

const FETCH_RESOURCE = require('../../../graphql/fetchResource.graphql');

interface Props {
  toggleModal?: any;
  modalIsOpen?: boolean;
  collectionId?: string;
  collectionExternalId?: string;
  errors: any;
  touched: any;
  isSubmitting: boolean;
  fetchResource: any;
  isFetched(boolean): boolean;
  fetched: boolean;
  name: string;
  summary: string;
  image: string;
  url: string;
  onName(string): string;
  onSummary(string): string;
  onImage(string): string;
  onUrl(string): string;
}

interface FormValues {
  fetchUrl: string;
}

interface MyFormProps {
  collectionId: string;
  collectionExternalId: string;
  toggleModal: any;
  fetchResource: any;
  isFetched(boolean): boolean;
  fetched: boolean;
  onName(string): string;
  onSummary(string): string;
  onImage(string): string;
  onUrl(string): string;
  name: string;
  summary: string;
  image: string;
  url: string;
}

const withFetchResource = graphql<{}>(FETCH_RESOURCE, {
  name: 'fetchResource'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const CreateCommunityModal = (props: Props & FormikProps<FormValues>) => {
  const { toggleModal, modalIsOpen } = props;
  return (
    <Modal isOpen={modalIsOpen} toggleModal={toggleModal}>
      <Container>
        <Header>
          <H5>
            <Trans>Add a new resource</Trans>
          </H5>
        </Header>
        <Row>
          <ContainerForm>
            <Form>
              <Field
                name="fetchUrl"
                render={({ field }) => (
                  <Text
                    placeholder={tt.placeholders.url}
                    onChange={field.onChange}
                    name={field.name}
                    value={field.value}
                  />
                )}
              />
              <Span disabled={props.isSubmitting} type="submit">
                <Search width={18} height={18} strokeWidth={2} color={'#333'} />
              </Span>
              {/* <LoaderButton loading={props.isSubmitting}  text={tt.placeholders.submit}  /> */}
            </Form>
          </ContainerForm>
        </Row>
        {props.isSubmitting ? (
          <WrapperLoader>
            <Loader />
          </WrapperLoader>
        ) : null}
        {props.fetched ? (
          <Fetched
            url={props.url}
            name={props.name}
            image={props.image}
            summary={props.summary}
            collectionId={props.collectionId}
            toggleModal={props.toggleModal}
            collectionExternalId={props.collectionExternalId}
            isFetched={props.isFetched}
          />
        ) : null}
      </Container>
    </Modal>
  );
};

const ModalWithFormik = withFormik<MyFormProps, FormValues>({
  mapPropsToValues: props => ({
    fetchUrl: ''
  }),
  validationSchema: Yup.object().shape({
    fetchUrl: Yup.string().url
  }),
  handleSubmit: (values, { props, setSubmitting }) => {
    props.isFetched(false);
    props.onName('');
    props.onSummary('');
    props.onImage('');
    props.onUrl(values.fetchUrl);
    return props
      .fetchResource({
        variables: {
          url: values.fetchUrl
        }
      })
      .then(res => {
        props.onName(res.data.fetchWebMetadata.title);
        props.onSummary(res.data.fetchWebMetadata.summary);
        props.onImage(res.data.fetchWebMetadata.image);
        props.onUrl(values.fetchUrl);
        props.isFetched(true);
        setSubmitting(false);
      })
      .catch(err => {
        props.onUrl(values.fetchUrl);
        props.isFetched(true);
        setSubmitting(false);
      });
  }
})(CreateCommunityModal);

export default compose(
  withFetchResource,
  withState('fetched', 'isFetched', false),
  withState('name', 'onName', ''),
  withState('summary', 'onSummary', ''),
  withState('image', 'onImage', ''),
  withState('url', 'onUrl', '')
)(ModalWithFormik);

const WrapperLoader = styled.div`
  padding: 10px;
`;

const Span = styled.button`
  position: absolute;
  right: 2px;
  top: 2px;
  border: 0;
  background: transparent;
  box-shadow: none;
  width: 40px;
  background: #fffffff0;
  height: 37px;
  cursor: pointer;
  &:hover {
    background: ${props => props.theme.styles.colour.primary};
  }
`;

const Container = styled.div`
  font-family: ${props => props.theme.styles.fontFamily};
  & form {
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
  position: relative;
  & form {
    width: 100%;
  }
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
