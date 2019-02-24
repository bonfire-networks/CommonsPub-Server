import * as React from 'react';
import { compose, withHandlers, withState } from 'recompose';
import { graphql, OperationOption } from 'react-apollo';
import { Redirect, Route, RouteComponentProps } from 'react-router-dom';
import { Col, Row } from '@zendeskgarden/react-grid';
import { withTheme } from '@zendeskgarden/react-theming';

import { i18nMark } from '@lingui/react';
import { Trans } from '@lingui/macro';

import styled, { ThemeInterface } from '../../themes/styled';
import Logo from '../../components/brand/Logo/Logo';
// import Link from '../../components/elements/Link/Link';
import LanguageSelect from '../../components/inputs/LanguageSelect/LanguageSelect';
import Body from '../../components/chrome/Body/Body';
// import Button from '../../components/elements/Button/Button';
import H6 from '../../components/typography/H6/H6';
// import P from '../../components/typography/P/P';
import LoginForm from './LoginForm';
// import User from '../../types/User';
import { ValidationField, ValidationObject, ValidationType } from './types';

const { getUserQuery } = require('../../graphql/getUser.client.graphql');
const { setUserMutation } = require('../../graphql/setUser.client.graphql');
// TODO make the login mutation also retrieve the user so a separate request is not necessary
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

const Head = styled.div`
  width: 100%;
  background: whitesmoke;
  height: 60px;
  & h1 {
    margin: 0;
    line-height: 60px;
  }
`;

const Signup = styled.div`
  margin-top: 16px;

  & u {
    cursor: pointer;
  }
`;

const Left = styled.div`
  float: left;
`;

const Right = styled.div`
  float: right;
  margin-top: 9px;
`;

const BodyCenterContent = styled(Body)`
  display: flex;
  align-items: center;
  width: 420px;
  margin: 0 auto;
  flex-direction: column;
`;

// const Banner = styled.div`
//   flex: 1;
//   background: #ffc9c9;
//   width: 100%;
//   text-align: center;
//   font-size: 15px;
//   color: #5e1919;
//   height: 60px;
//   line-height: 60px;
//   font-weight: 700;
//   max-height: 60px;
// `;

/**
 * @param Component
 * @param data {Object} the user object from local cache
 * @param rest
 * @constructor
 */
function RedirectIfAuthenticated({ component: Component, data, ...rest }) {
  console.log(data);
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
      alert(err);
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

    // delete userData.token;
    // console.log(userData);

    await this.props.setLocalUser({
      variables: {
        isAuthenticated: true,
        data: {
          ...userData.me.user,
          email: result.data.createSession.me.email
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
    console.log(this.props);
    if (this.state.redirectTo) {
      return <Redirect to={this.state.redirectTo as any} />;
    }

    return (
      <>
        <BodyCenterContent>
          {/* <Banner>
            <Trans>
              We're having some teething problems right now, but will be back
              soon! Keep checking back.
            </Trans>
          </Banner> */}
          <Head>
            <Col size={12}>
              <Left>
                <Logo />
              </Left>
              <Right>
                <LanguageSelect />
              </Right>
            </Col>
          </Head>
          <Row>
            <Col>
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
            </Col>
          </Row>

          {/* <Row>
          <Col>
            <P
              style={{
                marginTop: '40px'
              }}
            >
              <Trans>
                You need to sign up to participate in discussions. You can use a
                social media account to sign in, or create an account manually.
              </Trans>
            </P>

            <Link to="/sign-up">
              <Button>
                <Trans>Create an account</Trans>
              </Button>
            </Link>
          </Col>
        </Row> */}
          <SignupModal
            toggleModal={this.props.handleSignup}
            modalIsOpen={this.props.isOpen}
          />
        </BodyCenterContent>
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
