import * as React from 'react';
import styled from '../../../themes/styled';
import { clearFix } from 'polished';
import OutsideClickHandler from 'react-outside-click-handler';
import Textarea from '../../inputs/TextArea/Textarea';
import Button from '../Button/Button';
import { FormikProps, Form, Field } from 'formik';
import Alert from '../../elements/Alert';

interface Props {
  onToggle(boolean): boolean;
  toggle: boolean;
  id: string;
  createThread: any;
}

interface FormValues {
  content: string;
}

const Component = (props: Props & FormikProps<FormValues>) => (
  <ContainerTalk expanded={props.toggle}>
    <OutsideClickHandler onOutsideClick={() => props.onToggle(false)}>
      <Form>
        <Expanded expanded={props.toggle}>
          <Field
            name="content"
            render={({ field }) => (
              <>
                <PreviewTalk
                  expanded={props.toggle}
                  onClick={() => props.onToggle(true)}
                  placeholder={'Write a public message'}
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
          <Button disabled={props.isSubmitting} type="submit">
            Publish
          </Button>
        </Actions>
      </Form>
    </OutsideClickHandler>
  </ContainerTalk>
);

export default Component;

const Expanded = styled.div<{ expanded?: boolean }>`
  height: ${props => (props.expanded ? '150px' : '50px !important')};
  transition: height 0.3s ease-out;
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

const ContainerTalk = styled.div<{ expanded?: boolean }>`
  width: 720px;
  margin: 0 auto;
  border: 2px solid #c9c9c9 !important;
  border-radius: 3px;
  margin-bottom: 16px;
  &:hover {
    border-color: #848383 !important;
  }
`;

const PreviewTalk = styled(Textarea)<{ expanded?: boolean }>`
  height: 50px;
  border-radius: ${props =>
    props.expanded ? '3px 3px 0 0 !important' : '3px !important'};
  border: none !important;
  line-height: 48px;
  padding: 0 10px;
  font-size: 14px;
  color: #c1bdbd;
  font-weight: 600;
  &:hover {
    border: none !important;
  }
  &:focus {
    border: none !important;
    box-shadow: none !important;
    height: 150px;
  }
`;
