import * as React from 'react';
import { Col, Row } from '@zendeskgarden/react-grid';
import { Label, Message, TextField } from '@zendeskgarden/react-textfields';

import styled from '../../themes/styled';
import TextInput from '../../components/inputs/Text/Text';
// import Link from '../../components/elements/Link/Link';
import { LoaderButton } from '../../components/elements/Button/Button';
import { ValidationField, ValidationObject, ValidationType } from './types';

import { Trans } from '@lingui/macro';
import { i18nMark } from '@lingui/react';

const tt = {
  login: i18nMark('Sign in'),
  placeholders: {
    email: i18nMark('Enter your email'),
    password: i18nMark('Enter your password')
  }
};

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
  email: string;
  password: string;
};

export default class extends React.Component<LoginFormProps, LoginFormState> {
  state = {
    email: '',
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
              <Label>
                <Trans>Email address</Trans>:
              </Label>
              <TextInput
                placeholder={tt.placeholders.email}
                value={this.state.email}
                validation={this.getValidation(ValidationField.email)}
                onChange={(evt: any) => {
                  this.setState({
                    email: evt.target.value
                  });
                  onInputChange(ValidationField.email, evt.target.value);
                }}
              />
              <Message validation={this.getValidation(ValidationField.email)}>
                {this.getValidationMessage(ValidationField.email)}
              </Message>
            </TextField>
            <Spacer />
            <TextField>
              <Label>
                <Trans>Password</Trans>:
              </Label>
              <TextInput
                type="password"
                placeholder={tt.placeholders.password}
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
          {/* <SubmitCol>
            <Link to="/reset-password">
              <Trans>Forgotten your password?</Trans>
            </Link>
          </SubmitCol> */}
          <SubmitCol alignRight>
            <LoaderButton loading={authenticating} text={tt.login} />
          </SubmitCol>
        </Row>
      </LoginForm>
    );
  }
}
