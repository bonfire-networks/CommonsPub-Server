import * as React from 'react';
import Modal from '../Modal';
import styled from '../../../themes/styled';

import { Trans } from '@lingui/macro';

import { clearFix } from 'polished';
import H5 from '../../typography/H5/H5';
import Button from '../Button/Button';
import { Form } from 'formik';
import Comment from '../Comment/Comment';

// import gql from 'graphql-tag';

interface Props {
  toggleModal?: any;
  modalIsOpen?: boolean;
  values: any;
  isSubmitting: boolean;
  // user: any;
  selectThread(number): number;
}

const PreviewModal = (props: Props) => {
  const { toggleModal, modalIsOpen } = props;
  // let author = {
  //   localId: props.user.data.localId,
  //   name: props.user.data.name,
  //   icon: props.user.data.icon
  // };
  let message = {
    body: props.values.content,
    date: new Date().getTime(),
    id: new Date().toISOString()
  };
  return (
    <Modal isOpen={modalIsOpen} toggleModal={toggleModal}>
      <Container>
        <Header>
          <H5>
            <Trans>Preview</Trans>
          </H5>
        </Header>
        <Form>
          <Comment
            selectThread={props.selectThread}
            noAuthor
            comment={message}
            noAction
          />
          <Preview />
          <Actions>
            <Button disabled={props.isSubmitting} type="submit">
              <Trans>Post</Trans>
            </Button>
            <Button hovered onClick={() => props.toggleModal(false)}>
              <Trans>Cancel</Trans>
            </Button>
          </Actions>
        </Form>
      </Container>
    </Modal>
  );
};

export default PreviewModal;

const Preview = styled.div`
  font-family: ${props => props.theme.styles.fontFamily};
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
    margin-left: 8px;
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
