import * as React from 'react';
import styled, { css } from '../../../themes/styled';
import { clearFix } from 'polished';
import OutsideClickHandler from 'react-outside-click-handler';
import Textarea from '../../inputs/TextArea/Textarea';
import Button from '../Button/Button';
import { FormikProps, Field } from 'formik';
import Alert from '../../elements/Alert';
import { compose, withState } from 'recompose';
import Preview from './Preview';
const { getUserQuery } = require('../../../graphql/getUser.client.graphql');
import { graphql } from 'react-apollo';
import MarkdownModal from '../MarkdownModal';
import { Trans } from '@lingui/macro';
import { i18nMark } from '@lingui/react';
import { Type } from '../Icons';

const tt = {
  placeholders: {
    message: i18nMark('Write a public message')
  }
};

interface Props {
  onToggle(boolean): boolean;
  toggle: boolean;
  data: any;
  id: string;
  createThread: any;
  isOpen: boolean;
  onOpen(boolean): boolean;
  onModalIsOpen: any;
  modalIsOpen: boolean;
  selectThread(number): number;
  full: boolean;
}

interface FormValues {
  content: string;
}

const Component = (props: Props & FormikProps<FormValues>) => (
  <>
    <ContainerTalk
      full={props.full}
      expanded={props.full ? true : props.toggle}
    >
      {props.full ? (
        <div
          style={{
            height: '100%',
            display: 'flex',
            flexDirection: 'column',
            marginBottom: 0
          }}
        >
          <Expanded full={props.full}>
            <Field
              name="content"
              render={({ field }) => (
                <>
                  <PreviewTalk
                    full={props.full}
                    expanded={props.toggle}
                    onClick={() => props.onToggle(true)}
                    placeholder={tt.placeholders.message}
                    onChange={field.onChange}
                    name={field.name}
                    value={field.value}
                  />
                  {props.errors.content &&
                    props.touched.content && (
                      <Alert>{props.errors.content}</Alert>
                    )}
                </>
              )}
            />
          </Expanded>
          <Actions expanded={props.full} style={{ marginBottom: '40px' }}>
            <Left onClick={() => props.onModalIsOpen(true)}>
              <span>
                <Type width={16} height={16} strokeWidth={2} color={'#777'} />
              </span>
            </Left>
            <Button
              disabled={!props.values.content}
              onClick={() => props.onOpen(true)}
            >
              <Trans>Preview</Trans>
            </Button>
          </Actions>
          <Preview
            isSubmitting={props.isSubmitting}
            toggleModal={props.onOpen}
            modalIsOpen={props.isOpen}
            values={props.values}
            user={props.data.user}
            selectThread={props.selectThread}
          />
        </div>
      ) : (
        <OutsideClickHandler onOutsideClick={() => props.onToggle(false)}>
          <Expanded full={props.full} expanded={props.toggle}>
            <Field
              name="content"
              render={({ field }) => (
                <>
                  <PreviewTalk
                    expanded={props.toggle}
                    onClick={() => props.onToggle(true)}
                    placeholder={tt.placeholders.message}
                    onChange={field.onChange}
                    name={field.name}
                    value={field.value}
                  />
                  {props.errors.content &&
                    props.touched.content && (
                      <Alert>{props.errors.content}</Alert>
                    )}
                </>
              )}
            />
          </Expanded>
          <Actions expanded={props.toggle}>
            <Left onClick={() => props.onModalIsOpen(true)}>
              <span>
                <Type width={16} height={16} strokeWidth={2} color={'#777'} />
              </span>
            </Left>
            <Button
              disabled={!props.values.content}
              onClick={() => props.onOpen(true)}
            >
              <Trans>Preview</Trans>
            </Button>
          </Actions>
          <Preview
            isSubmitting={props.isSubmitting}
            toggleModal={props.onOpen}
            modalIsOpen={props.isOpen}
            values={props.values}
            user={props.data.user}
            selectThread={props.selectThread}
          />
        </OutsideClickHandler>
      )}
    </ContainerTalk>
    <MarkdownModal
      toggleModal={props.onModalIsOpen}
      modalIsOpen={props.modalIsOpen}
    />
  </>
);

export default compose(
  graphql(getUserQuery),
  withState('modalIsOpen', 'onModalIsOpen', false)
)(Component);

const Left = styled.div<{ expanded?: boolean }>`
  float: left;
  font-size: 14px;
  font-weight: 500;
  margin: 8px 0;
  cursor: pointer;
  & span {
    width: 26px;
    height: 26px;
    background: #dde3e8;
    display: inline-block;
    text-align: center;
    border-radius: 2px;
    vertical-align: middle;
    margin-left: 4px;
    &:hover {
      background: #ced6e6;
    }
    & svg {
      margin-top: 4px;
    }
  }
`;
const Expanded = styled.div<{ expanded?: boolean; full?: boolean }>`
  height: ${props => (props.expanded ? '150px' : '50px !important')};
  transition: height 0.3s ease-out;
  ${props =>
    props.full &&
    css`
      height: 100%;
      flex: 1;
      margin-bottom: 0px;
    `};
`;
const Actions = styled.div<{ expanded?: boolean }>`
  flex-direction: row;
  align-items: baseline;
  justify-content: space-between;
  border-bottom-left-radius: 3px;
  border-bottom-right-radius: 3px;
  background: #f5f5f5;
  padding: 4px;

  display: ${props => (props.expanded ? 'block' : 'none')};
  ${clearFix()};
  & button {
    float: right;
  }
`;

const ContainerTalk = styled.div<{ expanded?: boolean; full?: boolean }>`
  // margin: 0 auto;
  // border: 2px solid #c9c9c9 !important;
  // border-radius: 3px;
  // margin-bottom: 16px;
  ${props =>
    props.full &&
    css`
      height: 100%;
    `} &:hover {
    border-color: #848383 !important;
  }
`;

const PreviewTalk = styled(Textarea)<{ expanded?: boolean; full?: boolean }>`
  height: 50px;
  border-radius: ${props =>
    props.expanded ? '3px 3px 0 0 !important' : '3px !important'};
  border: none !important;
  line-height: 20px;
  padding: 0 10px;
  font-size: 14px;
  color: #333;
  font-weight: 600;
  ${props =>
    props.full &&
    css`
      height: 100%;
      min-height: 100%;
    `}
  &:hover {
    border: none !important;
  }
  &:focus {
    border: none !important;
    box-shadow: none !important;
    height: 150px;
    ${props =>
      props.full &&
      css`
        height: 100%;
        min-height: 100%;
      `}
`;
