import * as React from 'react';
import { Link } from 'react-router-dom';
import { Row, Col } from '@zendeskgarden/react-grid';
import { TextField, Label } from '@zendeskgarden/react-textfields';

import styled from '../../themes/styled';
import TextInput from '../../components/inputs/Text/Text';
import Button from '../../components/elements/Button/Button';
import Loader from '../../components/elements/Loader/Loader';

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

export default ({ onLoginFormSubmit, authenticating }) => (
  <LoginForm onSubmit={onLoginFormSubmit}>
    <Row>
      <Col>
        <TextField>
          <Label>Username:</Label>
          <TextInput required placeholder="Enter your username" />
        </TextField>
        <Spacer />
        <TextField>
          <Label>Password:</Label>
          <TextInput
            required
            type="password"
            placeholder="Enter your password"
          />
        </TextField>
      </Col>
    </Row>
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
