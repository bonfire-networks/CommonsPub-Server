import * as React from 'react';
import compose from 'recompose/compose';
import { graphql, OperationOption } from 'react-apollo';
import { Route, Redirect, RouteComponentProps } from 'react-router-dom';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';
import { withTheme } from '@zendeskgarden/react-theming';

import styled from '../../themes/styled';
import Logo from '../../components/brand/Logo/Logo';
import LanguageSelect from '../../components/inputs/LanguageSelect/LanguageSelect';
import Body from '../../components/chrome/Body/Body';
import Button from '../../components/elements/Button/Button';
import H6 from '../../components/typography/H6/H6';
import P from '../../components/typography/P/P';
import LoginForm from './LoginForm';
import { ThemeInterface } from '../../themes/styled';

const { GetUserQuery } = require('../../graphql/GET_USER.client.graphql');
const { SetUserQuery } = require('../../graphql/SET_USER.client.graphql');

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
  updateUser?: Function;
  data: object;
  theme: ThemeInterface;
}

interface LoginState {
  redirectTo: string | null;
  authenticating: boolean;
}

class Login extends React.Component<LoginProps, LoginState> {
  state = {
    redirectTo: null,
    authenticating: false
  };

  constructor(props) {
    super(props);
    this.onLoginFormSubmit = this.onLoginFormSubmit.bind(this);
  }

  /**
   * Submit the login form credentials to authenticate the user.
   * TODO implement real auth + validation when we know what the backend looks like
   * @param e {Event}
   */
  async onLoginFormSubmit(e) {
    e.preventDefault();

    this.setState({
      authenticating: true
    });

    setTimeout(async () => {
      if (this.props.updateUser) {
        await this.props.updateUser({
          variables: {
            isAuthenticated: true,
            user: {}
          }
        });

        this.setState({
          redirectTo: '/'
        });
      }
    }, 1000);
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
            {/* TODO why need to display: flex? */}
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
                Log in using your social media account
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
                ———
                <span
                  style={{
                    color: 'grey',
                    display: 'inline-block',
                    margin: '0 3px'
                  }}
                >
                  OR
                </span>
                ———
              </P>
              <LoginForm
                onLoginFormSubmit={this.onLoginFormSubmit}
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
                <Button>Create account</Button>
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

type User = {
  isAuthenticated: boolean;
  user: object;
};

export interface Args {
  data: User;
}

// get the user auth object from local cache
const withUser = graphql<{}, Args>(GetUserQuery);

// get user mutation resolver so we can set the user in the local cache
const withUserAuthentication = graphql<{}, Args>(SetUserQuery, {
  name: 'updateUser'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

export default compose(
  withTheme,
  withUser,
  withUserAuthentication
)(RedirectIfAuthenticated);
