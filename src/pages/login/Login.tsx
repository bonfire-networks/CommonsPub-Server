import * as React from 'react';
import { compose, withHandlers, withState } from 'recompose';
import { graphql, OperationOption } from 'react-apollo';
import { Redirect, Route, RouteComponentProps } from 'react-router-dom';
import { Col, Row } from '@zendeskgarden/react-grid';
import { withTheme } from '@zendeskgarden/react-theming';
import media from 'styled-media-query';
import { i18nMark } from '@lingui/react';
import { Trans } from '@lingui/macro';
import styled, { ThemeInterface } from '../../themes/styled';
import Logo from '../../components/brand/Logo/Logo';
import LanguageSelect from '../../components/inputs/LanguageSelect/LanguageSelect';
import H6 from '../../components/typography/H6/H6';
import LoginForm from './LoginForm';
import { ValidationField, ValidationObject, ValidationType } from './types';

const { getUserQuery } = require('../../graphql/getUser.client.graphql');
const { setUserMutation } = require('../../graphql/setUser.client.graphql');
const { loginMutation } = require('../../graphql/login.graphql');
import SignupModal from '../../components/elements/SignupModal';

const tt = {
  with: {
    fb: i18nMark('Sign in with Facebook'),
    g: i18nMark('Sign in with Google'),
    tw: i18nMark('Sign in with Twitter')
  },
  validation: {
    email: i18nMark('The email field cannot be empty'),
    password: i18nMark('The password field cannot be empty'),
    credentials: i18nMark(
      'Could not log in. Please check your credentials or use the link below to reset your password.'
    )
  }
};

const Signup = styled.div`
  margin-top: 16px;

  & u {
    cursor: pointer;
  }
`;

const BodyCenterContent = styled.div`
  margin: 0 auto;
  margin-top: 36px;
  padding: 0 16px;
`;

const WrapperLogin = styled.div`
  padding: 24px;
  padding-top: 24px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 24px 4px rgba(100, 100, 100, 0.1);
  padding-top: 1px;
`;

const LanguageWrapper = styled.div`
  margin-top: 24px;
  margin-bottom: 24px;
  & div {
    background: white !important;
    color: ${props => props.theme.styles.colour.base1} !important;
  }
`;
const Background = styled.div`
  background-image: url('https://i.imgur.com/UjieHFO.png');
  background-size: cover;
  background-repeat: no-repeat;
  height: 100%;
  ${media.lessThan('medium')`
  display: none;
  `};
`;
const Tagline = styled.h5`
  font-size: 36px;
  margin-top: 24px;
  margin-bottom: 24px;
`;
const Roww = styled(Row)`
  width: 1040px;
  ${media.lessThan('medium')`
   width: 100%;
   `};
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
  handleSignup(): boolean;
  isOpen: boolean;
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
        message: tt.validation.email
      } as ValidationObject);
    }
    if (!credentials.password.length) {
      validation.push({
        field: ValidationField.password,
        type: ValidationType.error,
        message: tt.validation.password
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
    } catch (err) {
      // alert(err);
      this.setState({
        authenticating: false,
        validation: [
          {
            field: null,
            type: ValidationType.warning,
            message: tt.validation.credentials
          } as ValidationObject
        ]
      });
      return;
    }

    this.setState({ authenticating: false });

    const userData = result.data.createSession;

    // TODO pull key out into constant
    localStorage.setItem('user_access_token', userData.token);
    localStorage.setItem('user_data', JSON.stringify(userData.me.user));
    // delete userData.token;
    console.log(userData);

    await this.props.setLocalUser({
      variables: {
        isAuthenticated: true,
        data: {
          ...userData.me.user
          // email: result.data.createSession.me.email
        }
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
      <>
        <BodyCenterContent>
          <Roww>
            <Col md={5} sm={12}>
              <Logo big />
              <Tagline>Share. Curate. Discuss.</Tagline>

              <WrapperLogin>
                <H6>
                  <Trans>Sign in</Trans>
                </H6>

                <LoginForm
                  validation={this.state.validation}
                  onSubmit={this.onLoginFormSubmit}
                  onInputChange={this.onLoginFormInputChange}
                  authenticating={this.state.authenticating}
                />
                <Signup>
                  <Trans>Don't yet have an account?</Trans>{' '}
                  <u onClick={this.props.handleSignup}>
                    <Trans>Sign up</Trans>
                  </u>
                </Signup>
              </WrapperLogin>
              <LanguageWrapper>
                <LanguageSelect />
              </LanguageWrapper>
            </Col>
            <Col md={7}>
              <Background />
            </Col>
          </Roww>

          <SignupModal
            toggleModal={this.props.handleSignup}
            modalIsOpen={this.props.isOpen}
          />
        </BodyCenterContent>
        {/* <Banner>
            <Trans>
              Seeing some error messages? Just hit refresh! Contact us if that
              didn't help, of course.
            </Trans>
          </Banner>
          </div> */}
      </>
    );
  }
}

export interface Args {
  data: {
    isAuthenticated: boolean;
    user: any;
  };
}

// get the user auth object from local cache
const withUser = graphql<{}, Args>(getUserQuery);

// get user mutation so we can set the user in the local cache
const withSetLocalUser = graphql<{}, Args>(setUserMutation, {
  name: 'setLocalUser'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

// to login via the API
const withLogin = graphql<{}, Args>(loginMutation, {
  name: 'login'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

export default compose(
  withTheme,
  withUser,
  withSetLocalUser,
  withLogin,
  withState('isOpen', 'onOpen', false),
  withHandlers({
    handleSignup: props => () => props.onOpen(!props.isOpen)
  })
)(RedirectIfAuthenticated);
