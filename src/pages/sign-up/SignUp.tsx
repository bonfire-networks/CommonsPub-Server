import * as React from 'react';
import { Redirect, RouteComponentProps } from 'react-router';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';
import { graphql, OperationOption } from 'react-apollo';
import compose from 'recompose/compose';

import styled, { StyledThemeInterface } from '../../themes/styled';
import Logo from '../../components/brand/Logo/Logo';
import Body from '../../components/chrome/Body/Body';
import PreviousStep from './PreviousStep';
import Step1 from './Step1';
import Step2 from './Step2';
import UserProfile from '../user/UserProfile';
import User from '../../types/User';
import Button, { LoaderButton } from '../../components/elements/Button/Button';
import { Args } from '../login/Login';
import { Interests, Languages, SignUpProfileSection } from './Profile';
import { getDataURL, scrollTo, generateEmojiId } from './util';

const { userCreateMutation } = require('../../graphql/userCreate.graphql');
const { setUserQuery } = require('../../graphql/setUser.client.graphql');

const SignUpBody = styled(Body)`
  display: flex;
  flex-direction: row;
`;

//TODO media queries/responsivity
const Sidebar = styled.div`
  width: 25%;
  min-width: 500px;
  height: 100%;
  padding: 25px;
  background-color: ${(props: StyledThemeInterface) =>
    props.theme.styles.colour.base5};
`;

const stepScrollTo = {
  1: 0,
  2: 450
};

interface RegisterResult {
  data: {
    userCreate: any;
    errors?: [];
  };
}

interface SignUpUser extends User {
  password: string;
}

interface SignUpMatchParams {
  step: string;
}

interface SignUpState {
  registering: boolean;
  redirect?: string | null;
  currentStep: number;
  user: SignUpUser;
}

interface SignUpProps extends RouteComponentProps<SignUpMatchParams> {
  setLocalUser: Function;
  register: (
    {
      variables: { user: object }
    }
  ) => RegisterResult;
}

class SignUp extends React.Component<SignUpProps, SignUpState> {
  static stepComponents = [Step1, Step2];

  // container of the user profile, ref. is used
  // to scroll container on sign up step change
  _profileElem: HTMLElement;

  state: SignUpState = {
    currentStep: -1,
    registering: false,
    user: {
      name: '',
      email: '',
      bio: '',
      password: '',
      preferredUsername: generateEmojiId(),
      avatarImage: undefined,
      profileImage: undefined,
      location: '',
      language: 'en-gb',
      interests: [] as string[],
      languages: [] as string[]
    } as SignUpUser
  };

  constructor(props) {
    super(props);

    this.state.currentStep = Number(props.match.params.step);

    if (!this.state.user.name && this.state.currentStep > 1) {
      this.state.redirect = '/sign-up/1';
      return;
    }

    // FIXME an error occurs when methods are passed by ref after binding if:
    //  - user goes straight to /sign-up/2/
    //  - gets redirects to /sign-up/1
    //  - clicks something to invoke bound method (e.g. Continue btn which calls #goToNextStep)
    // this.randomizeEmojiId = this.randomizeEmojiId.bind(this);
    // this.linkUserState = this.linkUserState.bind(this);
    // this.goToPreviousStep = this.goToPreviousStep.bind(this);
    // this.toggleUserInterest = this.toggleUserInterest.bind(this);
    // this.createSetUserImageCallback = this.createSetUserImageCallback.bind(this);
    // this.goToNextStep = this.goToNextStep.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    this.state.redirect = null;
    this.state.currentStep = Number(nextProps.match.params.step);
    this.scrollForStep(this.state.currentStep);
  }

  getStepComponent() {
    const stepIdx = this.state.currentStep - 1;
    let Step = SignUp.stepComponents[stepIdx];
    if (!Step) {
      return null;
    }
    return (
      <Step
        {...{
          user: this.state.user,
          goToNextStep: this.goToNextStep.bind(this),
          goToPreviousStep: this.goToPreviousStep.bind(this),
          randomizeEmojiId: this.randomizeEmojiId.bind(this),
          linkUserState: this.linkUserState.bind(this),
          toggleInterest: this.toggleUserInterest.bind(this)
        }}
      />
    );
  }

  randomizeEmojiId() {
    this.setState({
      user: {
        ...this.state.user,
        preferredUsername: generateEmojiId()
      }
    });
  }

  goToPreviousStep() {
    const prevStep = Number(this.state.currentStep) - 1;
    if (prevStep > 0) {
      this.props.history.push(`/sign-up/${prevStep}`);
      this.scrollForStep(prevStep);
    }
  }

  private nextStepIndex() {
    return Number(this.state.currentStep) + 1;
  }

  private isFinalStep() {
    return this.nextStepIndex() > SignUp.stepComponents.length;
  }

  private getNextStepButton() {
    if (this.isFinalStep()) {
      return (
        <LoaderButton
          text="Sign up"
          loading={this.state.registering}
          onClick={() => this.doRegistration()}
        />
      );
    }
    return <Button onClick={() => this.goToNextStep()}>Continue</Button>;
  }

  private async goToNextStep() {
    const nextStep = this.nextStepIndex();
    this.props.history.push(`/sign-up/${nextStep}`);
    this.scrollForStep(nextStep);
  }

  private async doRegistration() {
    this.setState({ registering: true });

    let result: RegisterResult;

    try {
      const payload = {
        variables: {
          user: {
            email: this.state.user.email,
            preferredUsername: this.state.user.preferredUsername,
            password: this.state.user.password,
            summary: this.state.user.bio
          }
        }
      };

      result = await this.props.register(payload);

      this.setState({ registering: false });

      console.log(result);

      if (result.data.errors) {
        alert(JSON.stringify(result.data.errors));
        return;
      }
    } catch (err) {
      this.setState({ registering: false });
      console.log(err);
      alert('registration failed: ' + err.message);
      return;
    }

    alert('registration successful');

    const userData = result.data.userCreate;

    // TODO pull key out into constant
    localStorage.setItem('user_access_token', userData.token);

    delete userData.token;

    await this.props.setLocalUser({
      variables: {
        isAuthenticated: true,
        data: userData
      }
    });

    this.props.history.push('/');
  }

  private scrollForStep(step) {
    scrollTo(this._profileElem, stepScrollTo[step]);
  }

  /**
   * Produce a callback for an input's onChange prop that sets
   * the value of `field` at `this.state.user.{field}`.
   * @param field {String} field to create setter callback for
   **/
  linkUserState(field) {
    return evt =>
      this.setState({
        user: {
          ...this.state.user,
          [field]: evt.target.value
        }
      });
  }

  toggleUserInterest(interest: string) {
    let interests;
    if (this.state.user.interests.indexOf(interest) > -1) {
      interests = this.state.user.interests.filter(i => i !== interest);
    } else {
      interests = [...this.state.user.interests, interest];
    }
    this.setState({
      user: {
        ...this.state.user,
        interests
      }
    });
  }

  /**
   * Create function that loads an image from the user file system and set
   * as `imageTypeName` on the state so it can be displayed without uploading.
   * @param imageTypeName the type of image being set
   */
  createSetUserImageCallback(
    imageTypeName: 'profileImage' | 'avatarImage'
  ): (evt: React.SyntheticEvent) => void {
    return evt => {
      getDataURL(evt, result => {
        this.setState({
          user: {
            ...this.state.user,
            [imageTypeName]: result
          }
        });
      });
    };
  }

  private getNextStepName() {
    // TODO pull array out of class
    return ['your interests', 'discover'][this.state.currentStep - 1];
  }

  render() {
    if (!('step' in this.props.match.params)) {
      return <Redirect to="/sign-up/1" />;
    } else if (this.state.redirect) {
      return <Redirect to={this.state.redirect} />;
    }

    return (
      <SignUpBody>
        <Sidebar>
          <Grid
            style={{ height: '100%', display: 'flex', flexDirection: 'column' }}
          >
            <Row>
              <Col>
                <Logo link={false} />
                <PreviousStep
                  active={this.state.currentStep > 1}
                  onClick={() => this.goToPreviousStep()}
                  title={`Go back to Step ${this.state.currentStep - 1}`}
                >
                  &lt;
                </PreviousStep>
              </Col>
            </Row>
            {this.getStepComponent()}
            <Row style={{ flexGrow: 1 }} />
            <Row style={{ minHeight: '42px', marginTop: '10px' }}>
              {this.getNextStepName() ? (
                <Col
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    color: 'grey'
                  }}
                >
                  Next: {this.getNextStepName()}
                </Col>
              ) : null}
              <Col style={{ display: 'flex', justifyContent: 'flex-end' }}>
                {this.state.currentStep > 1 ? (
                  <>
                    <Button secondary onClick={() => this.goToNextStep()}>
                      Skip
                    </Button>
                    <div style={{ height: '10px', width: '10px' }} />
                  </>
                ) : null}
                {this.getNextStepButton()}
              </Col>
            </Row>
          </Grid>
        </Sidebar>
        <UserProfile
          innerRef={e => (this._profileElem = e)}
          user={this.state.user}
          setUserImage={type => this.createSetUserImageCallback(type)}
          body={({ containerProps }) => {
            return (
              <SignUpProfileSection {...containerProps}>
                <Languages
                  active={this.state.currentStep > 1}
                  languages={this.state.user.languages}
                />
                <Interests
                  onTagClick={interest => this.toggleUserInterest(interest)}
                  active={this.state.currentStep > 1}
                  interests={this.state.user.interests}
                />
              </SignUpProfileSection>
            );
          }}
        />
      </SignUpBody>
    );
  }
}

// get user mutation so we can set the user in the local cache
const withSetLocalUser = graphql<{}, Args>(setUserQuery, {
  name: 'setLocalUser'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const withRegister = graphql<{}, Args>(userCreateMutation, {
  name: 'register'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

export default compose(
  withSetLocalUser,
  withRegister
)(SignUp);
