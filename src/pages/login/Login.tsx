import * as React from 'react';
import compose from 'recompose/compose';
import { graphql, OperationOption } from 'react-apollo';
import { Redirect, Route, RouteComponentProps } from 'react-router-dom';
import { Col, Grid, Row } from '@zendeskgarden/react-grid';
import { withTheme } from '@zendeskgarden/react-theming';
import { Trans } from '@lingui/macro';

import styled, { ThemeInterface } from '../../themes/styled';
import Logo from '../../components/brand/Logo/Logo';
import Link from '../../components/elements/Link/Link';
import LanguageSelect from '../../components/inputs/LanguageSelect/LanguageSelect';
import Body from '../../components/chrome/Body/Body';
import Button from '../../components/elements/Button/Button';
import H6 from '../../components/typography/H6/H6';
import P from '../../components/typography/P/P';
import LoginForm from './LoginForm';
import User from '../../types/User';
import { ValidationField, ValidationObject, ValidationType } from './types';

const { getUserQuery } = require('../../graphql/getUser.client.graphql');
const { setUserQuery } = require('../../graphql/setUser.client.graphql');
const { loginMutation } = require('../../graphql/login.graphql');

const CenteredButtonGroup = styled.div`
  display: flex;
  justify-content: center;
`;

const FirstTimeCol = styled(Col)`
  display: flex;
  flex-direction: column;

  &:before {
    content: '';
    height: 95%;
    width: 1px;
    position: absolute;
    left: -11%;
    top: 2.5%;
    display: block;
    background-color: lightgrey;
  }
`;

const BodyCenterContent = styled(Body)`
  display: flex;
  align-items: center;
`;

const Spacer = styled.div`
  width: 10px;
  height: 10px;
`;

const LoginHeading = styled(H6)`
  text-shadow: 2px 2px 0 ${props => props.theme.styles.colour.base5};
`;

/**
 * @param Component
 * @param data {Object} the user object from local cache
 * @param rest
 * @constructor
 */
function RedirectIfAuthenticated({ component: Component, data, ...rest }) {
  return (
    <Route
      render={(props: RouteComponentProps & LoginProps) => {
        if (data.user.isAuthenticated) {
          return <Redirect to="/" />;
        }
        return <Login data={data} {...props} {...rest} />;
      }}
    />
  );
}

interface LoginProps extends RouteComponentProps {
  setLocalUser: Function;
  login: Function;
  data: object;
  theme: ThemeInterface;
}

interface LoginState {
  redirectTo: string | null;
  authenticating: boolean;
  validation: ValidationObject[];
}

type CredentialsObject = {
  email: string;
  password: string;
};
//
// const DEMO_CREDENTIALS = {
//   email: 'moodle@moodle.net',
//   password: 'moodle'
// };

class Login extends React.Component<LoginProps, LoginState> {
  state = {
    redirectTo: null,
    authenticating: false,
    validation: []
  };

  static validateCredentials(credentials: CredentialsObject) {
    const validation: ValidationObject[] = [];

    if (!credentials.email.length) {
      validation.push({
        field: ValidationField.email,
        type: ValidationType.error,
        message: 'The email field cannot be empty'
      } as ValidationObject);
    }
    if (!credentials.password.length) {
      validation.push({
        field: ValidationField.password,
        type: ValidationType.error,
        message: 'The password field cannot be empty'
      } as ValidationObject);
    }

    return validation;
  }

  constructor(props) {
    super(props);
    this.onLoginFormSubmit = this.onLoginFormSubmit.bind(this);
    this.onLoginFormInputChange = this.onLoginFormInputChange.bind(this);
  }

  /**
   * Submit the login form credentials to authenticate the user.
   * @param credentials {Object}
   */
  async onLoginFormSubmit(credentials) {
    const validation = Login.validateCredentials(credentials);

    if (validation.length) {
      this.setState({ validation });
      return;
    }

    this.setState({ authenticating: true });

    let result;

    try {
      result = await this.props.login({
        variables: credentials
      });

      console.log(result);
    } catch (err) {
      console.log(err);
      this.setState({
        authenticating: false,
        validation: [
          {
            field: null,
            type: ValidationType.warning,
            message:
              'Could not log in. Please check your credentials or use the link below to reset your password.'
          } as ValidationObject
        ]
      });
      return;
    }

    this.setState({ authenticating: false });

    const userData = result.data.login;

    // TODO pull key out into constant
    localStorage.setItem('user_access_token', userData.token);

    delete userData.token;

    await this.props.setLocalUser({
      variables: {
        isAuthenticated: true,
        data: userData
      }
    });
  }

  /** Clear the validation messages for a field and also generic validations when its value changes. */
  onLoginFormInputChange(field: ValidationField) {
    this.setState({
      validation: this.state.validation.filter(
        (validation: ValidationObject) => {
          return validation.field !== field && validation.field !== null;
        }
      )
    });
  }

  render() {
    if (this.state.redirectTo) {
      return <Redirect to={this.state.redirectTo as any} />;
    }

    return (
      <BodyCenterContent>
        <div
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            width: '100%',
            height: '8px',
            boxShadow: '0 0 1px lightgrey',
            backgroundColor: this.props.theme.styles.colour.primary
          }}
        />
        <Grid fluid={false}>
          <Row>
            <Col>
              <Logo />
            </Col>
            <Col
              justifyContent="end"
              alignSelf="center"
              style={{ display: 'flex' }}
            >
              <LanguageSelect />
            </Col>
          </Row>
          <Row>
            <Col md={6}>
              <LoginHeading>
                <Trans id="login.form.prompt">
                  Log in using your social media account
                </Trans>
              </LoginHeading>
              <CenteredButtonGroup>
                <Button
                  style={{ width: '33.33%' }}
                  title="Log in with Facebook"
                >
                  <i className="facebook" />
                </Button>
                <Spacer />
                <Button style={{ width: '33.33%' }} title="Log in with Google">
                  <i className="google" />
                </Button>
                <Spacer />
                <Button style={{ width: '33.33%' }} title="Log in with Twitter">
                  <i className="twitter" />
                </Button>
              </CenteredButtonGroup>
              <P
                style={{
                  textAlign: 'center',
                  color: 'lightgrey',
                  pointerEvents: 'none'
                }}
              >
                <span style={{ fontFamily: 'sans-serif' }}>———</span>
                <span
                  style={{
                    color: 'grey',
                    display: 'inline-block',
                    margin: '0 3px'
                  }}
                >
                  OR
                </span>
                <span style={{ fontFamily: 'sans-serif' }}>———</span>
              </P>
              <LoginForm
                validation={this.state.validation}
                onSubmit={this.onLoginFormSubmit}
                onInputChange={this.onLoginFormInputChange}
                authenticating={this.state.authenticating}
              />
            </Col>
            <FirstTimeCol offsetSm={1} md={5}>
              <Row>
                <LoginHeading>First time?</LoginHeading>
                {/*TODO why isn't the margin collapsing between the H6 & P?*/}
                <P style={{ marginTop: 0 }}>
                  You don't need an account to use{' '}
                  <span
                    style={{
                      color: this.props.theme.styles.colour.primary,
                      fontWeight: 'bold'
                    }}
                  >
                    MoodleNet
                  </span>
                  . You can browse as a guest using the button below.
                </P>
                <P>
                  To participate in discussions you need to sign up. Create an
                  account on the left or use a social media account to log in.
                </P>
              </Row>
              <Row
                style={{
                  marginTop: '20px'
                  // display: 'flex',
                  // alignItems: 'flex-end',
                  // flexGrow: 1,
                  // paddingBottom: '5%',
                }}
              >
                <Link to="/sign-up">
                  <Button>Create account</Button>
                </Link>
                <Spacer />
                <Button secondary>Browse as guest</Button>
              </Row>
            </FirstTimeCol>
          </Row>
        </Grid>
      </BodyCenterContent>
    );
  }
}

export interface Args {
  data: {
    isAuthenticated: boolean;
    user: User;
  };
}

// get the user auth object from local cache
const withUser = graphql<{}, Args>(getUserQuery);

// get user mutation so we can set the user in the local cache
const withSetLocalUser = graphql<{}, Args>(setUserQuery, {
  name: 'setLocalUser'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const withLogin = graphql<{}, Args>(loginMutation, {
  name: 'login'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

export default compose(
  withTheme,
  withUser,
  withSetLocalUser,
  withLogin
)(RedirectIfAuthenticated);
