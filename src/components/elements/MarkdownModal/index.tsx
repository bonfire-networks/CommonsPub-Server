import * as React from 'react';
import Modal from '../Modal';
import styled from '../../../themes/styled';

import { Trans } from '@lingui/macro';

import { clearFix } from 'polished';
import H5 from '../../typography/H5/H5';

interface Props {
  toggleModal?: any;
  modalIsOpen?: boolean;
}

const CreateCommunityModal = (props: Props) => {
  const { toggleModal, modalIsOpen } = props;
  return (
    <Modal isOpen={modalIsOpen} toggleModal={() => toggleModal(false)}>
      <Container>
        <Header>
          <H5>
            <Trans>Markdown Help</Trans>
          </H5>
        </Header>
        <Row big>
          <label>
            <Trans>Markdown</Trans>
          </label>
          <label>
            <Trans>Rendered output</Trans>
          </label>
        </Row>

        <Row>
          <label>
            <Trans>**bold**</Trans>
          </label>
          <b>
            <Trans>bold</Trans>
          </b>
        </Row>
        <Row>
          <label>
            <Trans>*italic*</Trans>
          </label>
          <i>
            <Trans>italic</Trans>
          </i>
        </Row>
        <Row>
          <label>
            <Trans>~~strikethrough~~</Trans>
          </label>
          <del>
            <Trans>strikethrough</Trans>
          </del>
        </Row>
        <Row>
          <label>
            <Trans>>blockquote</Trans>
          </label>
          <blockquote>
            <Trans>blockquote</Trans>
          </blockquote>
        </Row>
        <Row>
          <label>{`[link](http://new.moodle.net)`}</label>
          <label>
            <a href="http://new.moodle.net">link</a>
          </label>
        </Row>
        <Row>
          <label>
            {`![Image description](https://new.moodle.net/images/favicon.png)`}
          </label>
          <label>
            <img
              src="https://new.moodle.net/images/favicon.png"
              alt="Image description"
            />
          </label>
        </Row>

        <Row>
          <label>
            # Header 1 <br />
            ## Header 2 <br />
            ### Header 3
          </label>
          <label>
            <h1>Header 1</h1>
            <h2>Header 2</h2>
            <h3>Header 3</h3>
          </label>
        </Row>

        <Row>
          <label>
            <Trans>`code`</Trans>
          </label>
          <code>
            <Trans>code</Trans>
          </code>
        </Row>
        <Actions>
          <a href={`https://www.markdownguide.org/basic-syntax`} target="blank">
            <span>🎊</span>
            <Trans>More markdown tips</Trans>
            <span>🎊</span>
          </a>
        </Actions>
      </Container>
    </Modal>
  );
};

export default CreateCommunityModal;

const Container = styled.div`
  font-family: ${props => props.theme.styles.fontFamily};
`;
const Actions = styled.div`
  ${clearFix()};
  height: 60px;
  padding-top: 10px;
  padding-right: 10px;
  &:hover {
    background: rgba(192, 201, 200, 0.2);
    color: #2a2a2f;
  }
  & button {
    float: right;
  }
  & a {
    text-align: center;
    display: block;
    line-height: 45px;
    color: #4a4a4e;
    font-weight: 600;
    text-decoration: none;
    & span {
      padding: 0 4px;
      text-decoration: none;
    }
  }
`;

const Row = styled.div<{ big?: boolean }>`
  ${clearFix()};
  border-bottom: 1px solid rgba(151, 151, 151, 0.2);
  background: ${props => (props.big ? '#f7f8fb' : 'inehrit')};
  font-weight: ${props => (props.big ? '600' : '500')};
  font-size: 0.7rem;
  // height: 40px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  grid-column-gap: 8px;
  grid-row-gap: 8px;
  padding: 0 16px;
  // & img {
  //   width: 100%;
  //   height: auto;
  // }
  & code {
    overflow-x: auto;
    padding: 0 4px;
    border: 1px solid rgba(192, 201, 200, 0.4);
    background-color: rgba(192, 201, 200, 0.2);
    border-radius: 2px;
    font-size: 0.875em;
    word-wrap: break-word;
    display: inline-block;
    line-height: 30px;
    height: 30px;
    margin-top: 5px;
  }
  & blockquote {
    height: 30px;
    line-height: 30px;
    padding: 0;
    margin: 0;
    padding-left: 16px;
    border-left: 5px solid #cacaca;
    margin-top: 5px;
    border-radius: 0px;
    color: #cacaca;
    font-weight: 600;
  }
  & label,
  b,
  i,
  del {
    line-height: 40px;
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
