import * as React from 'react';
import { Link } from 'react-router-dom';
import { Col, Row } from '@zendeskgarden/react-grid';
import { Label, Message, TextField } from '@zendeskgarden/react-textfields';

import styled from '../../themes/styled';
import TextInput from '../../components/inputs/Text/Text';
import Button from '../../components/elements/Button/Button';
import Loader from '../../components/elements/Loader/Loader';
import { ValidationField, ValidationObject, ValidationType } from './types';

type SubmitColProps = {
  alignRight?: boolean;
};

const LoginForm = styled.form`
  margin: 15px 0;
`;

const SubmitCol = styled(Col)`
  display: flex;
  align-items: center;
  padding: 10px;
  justify-content: ${(props: SubmitColProps) =>
    props.alignRight ? 'flex-end' : 'flex-start'};
`;

const Spacer = styled.div`
  width: 10px;
  height: 10px;
`;

type LoginFormProps = {
  onSubmit: Function;
  onInputChange: Function;
  authenticating: boolean;
  validation: ValidationObject[];
};

type LoginFormState = {
  username: string;
  password: string;
};

export default class extends React.Component<LoginFormProps, LoginFormState> {
  state = {
    username: '',
    password: ''
  };

  constructor(props) {
    super(props);
    this.getValidation = this.getValidation.bind(this);
    this.getValidationMessage = this.getValidationMessage.bind(this);
  }

  getValidation(field: ValidationField | null): ValidationType | null {
    const validation = this.props.validation.find(
      (validation: ValidationObject) => {
        return validation.field === field;
      }
    );
    if (validation) {
      return validation.type;
    }
    return null;
  }

  getValidationMessage(field: ValidationField | null): String {
    return this.props.validation.reduce(
      (message: string, validation: ValidationObject) => {
        if (validation.field === field) {
          if (message.length) {
            return (message += ', ' + validation.message);
          } else {
            return validation.message;
          }
        }
        return message;
      },
      ''
    );
  }

  render() {
    const { onInputChange, onSubmit, authenticating } = this.props;

    return (
      <LoginForm
        onSubmit={evt => {
          evt.preventDefault();
          onSubmit(this.state);
        }}
      >
        <Row>
          <Col>
            <TextField>
              <Label>Username:</Label>
              <TextInput
                placeholder="Enter your username"
                value={this.state.username}
                validation={this.getValidation(ValidationField.username)}
                onChange={(evt: any) => {
                  this.setState({
                    username: evt.target.value
                  });
                  onInputChange(ValidationField.username, evt.target.value);
                }}
              />
              <Message
                validation={this.getValidation(ValidationField.username)}
              >
                {this.getValidationMessage(ValidationField.username)}
              </Message>
            </TextField>
            <Spacer />
            <TextField>
              <Label>Password:</Label>
              <TextInput
                type="password"
                placeholder="Enter your password"
                value={this.state.password}
                validation={this.getValidation(ValidationField.password)}
                onChange={(evt: any) => {
                  this.setState({
                    password: evt.target.value
                  });
                  onInputChange(ValidationField.password, evt.target.value);
                }}
              />
              <Message
                validation={this.getValidation(ValidationField.password)}
              >
                {this.getValidationMessage(ValidationField.password)}
              </Message>
            </TextField>
          </Col>
        </Row>
        {this.getValidationMessage(null) ? (
          <Row>
            <Col>
              <Message
                style={{ margin: '10px 0' }}
                validation={this.getValidation(null)}
              >
                {this.getValidationMessage(null)}
              </Message>
            </Col>
          </Row>
        ) : null}
        <Row>
          <SubmitCol>
            <Link to="/reset-password" title="Forgotten password">
              Forgotten password?
            </Link>
          </SubmitCol>
          <SubmitCol alignRight>
            <Button disabled={authenticating} type="submit">
              {authenticating ? <Loader /> : 'Sign in'}
            </Button>
          </SubmitCol>
        </Row>
      </LoginForm>
    );
  }
}
