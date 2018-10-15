import * as React from 'react';
import { Redirect, RouteComponentProps } from 'react-router';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faImage, faUser } from '@fortawesome/free-solid-svg-icons';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';

import styled, { StyledThemeInterface } from '../../themes/styled';
import Logo from '../../components/brand/Logo/Logo';
import Body from '../../components/chrome/Body/Body';
import H6 from '../../components/typography/H6/H6';
import PreviousStep from './PreviousStep';
import Step1 from './Step1';
import Step2 from './Step2';
import P from '../../components/typography/P/P';

const SignUpBody = styled(Body)`
  display: flex;
  flex-direction: row;
`;

//TODO media queries/responsivity
const Sidebar = styled.div`
  width: 25%;
  height: 100%;
  padding: 25px;
  background-color: ${(props: StyledThemeInterface) =>
    props.theme.styles.colour.base5};
`;

//TODO media queries/responsivity
const UserProfile = styled.div`
  width: 75%;
  height: 100%;
  margin-left: 1%;
  background-color: ${(props: StyledThemeInterface) =>
    props.theme.styles.colour.base5};
`;

//TODO don't use any props type
const UserProfileImage = styled.div<any>`
  position: relative;
  width: 100%;
  height: 400px;
  background-color: ${props => props.theme.styles.colour.base4};
  background-image: ${props =>
    props.backgroundImage
      ? `url(${props.backgroundImage}), linear-gradient(white, grey)`
      : ''};
  background-position: center;
  background-size: 100% auto;
  color: ${props => props.theme.styles.colour.base3};
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 6rem;
`;

const liftUserAvatar = -75;

//TODO don't use any props type
const UserAvatar = styled.div<any>`
  overflow: hidden;
  height: 150px;
  width: 150px;
  border-radius: 75px;
  background-color: ${props => props.theme.styles.colour.base3};
  background-image: ${props => `url(${props.backgroundImage})`};
  background-position: center;
  background-size: cover;
  background-repeat: no-repeat;
  color: ${props => props.theme.styles.colour.base5};
  position: relative;
  top: ${liftUserAvatar}px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 4rem;
`;

const UserDetails = styled.div`
  position: relative;
  top: ${liftUserAvatar}px;
  text-align: center;
`;

const FileInput = styled.input`
  cursor: pointer;
  height: calc(100% + 100px);
  width: 100%;
  position: absolute;
  top: -100px;
  left: 0;
`;

//TODO this should be offloaded to an API
function generateEmojiId(): string {
  const emojis = [
    '😀',
    '😃',
    '😣',
    '😐',
    '🤥',
    '🍏',
    '🍎',
    '🍐',
    '🍊',
    '🍋',
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '😀',
    '😃',
    '😄',
    '😁',
    '😆',
    '🌹',
    '💐',
    '🍁',
    '🐴'
  ];
  let id = '';
  for (let i = 0; i < 3; i++) {
    id += emojis[Math.floor(Math.random() * emojis.length)];
  }
  return id;
}

interface SignUpMatchParams {
  step: string;
}

interface SignUpState {
  currentStep: number;
  user: {
    username: string;
    password: string;
    email: string;
    emojiId: string;
    avatarImage?: string;
    profileImage?: string;
    role: string;
    location: string;
    language: string;
    interests: string[];
    languages: string[];
  };
}

interface SignUpProps extends RouteComponentProps<SignUpMatchParams> {}

const FadedFallbackText = ({ value, fallback }) =>
  value ? (
    <span>{value}</span>
  ) : (
    <span style={{ color: 'lightgrey' }}>{fallback}</span>
  );

const Interests = ({ interests }) => <div>interests</div>;

const Languages = ({ languages }) => <div>languages</div>;

export default class SignUp extends React.Component<SignUpProps, SignUpState> {
  static stepComponents = [Step1, Step2];

  state = {
    currentStep: -1,
    user: {
      username: '',
      password: '',
      email: '',
      emojiId: generateEmojiId(),
      avatarImage: undefined,
      profileImage: undefined,
      role: '',
      location: '',
      language: 'en-gb',
      interests: [] as string[],
      languages: [] as string[]
    }
  };

  constructor(props) {
    super(props);

    this.state.currentStep = Number(props.match.params.step);

    //TODO reinstate when dev for sign up is done
    // if (!this.state.user.username && this.state.currentStep > 1) {
    //   window.location.href = '/sign-up';
    //   return;
    // }

    this.randomizeEmojiId = this.randomizeEmojiId.bind(this);
    this.linkUserState = this.linkUserState.bind(this);
    this.goToNextStep = this.goToNextStep.bind(this);
    this.goToPreviousStep = this.goToPreviousStep.bind(this);
    this.toggleUserInterest = this.toggleUserInterest.bind(this);
    this.setUserImage = this.setUserImage.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    this.state.currentStep = Number(nextProps.match.params.step);
  }

  getStepComponent() {
    const stepProps = {
      user: this.state.user,
      goToNextStep: this.goToNextStep,
      goToPreviousStep: this.goToPreviousStep,
      randomizeEmojiId: this.randomizeEmojiId,
      linkUserState: this.linkUserState,
      toggleInterest: this.toggleUserInterest
    };
    const stepIdx = this.state.currentStep - 1;
    let Step = SignUp.stepComponents[stepIdx];
    if (!Step) {
      return null;
    }
    return <Step {...stepProps} />;
  }

  randomizeEmojiId() {
    this.setState({
      user: {
        ...this.state.user,
        emojiId: generateEmojiId()
      }
    });
  }

  goToPreviousStep() {
    const prevStep = Number(this.state.currentStep) - 1;
    if (prevStep > 0) {
      this.props.history.push(`/sign-up/${prevStep}`);
    }
  }

  goToNextStep() {
    const nextStep = Number(this.state.currentStep) + 1;
    if (nextStep > SignUp.stepComponents.length) {
      // the user has completed sign up, set them in the local cache and
      // redirect them to the homepage
      //TODO set in local cache
      this.props.history.push('/');
      return;
    }
    this.props.history.push(`/sign-up/${nextStep}`);
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

  setUserImage(name: string): (evt: React.SyntheticEvent) => void {
    return (evt: any) => {
      const reader = new FileReader();

      reader.addEventListener(
        'load',
        () => {
          this.setState({
            user: {
              ...this.state.user,
              [name]: reader.result as string
            }
          });
        },
        false
      );

      if (evt.target.files[0]) {
        reader.readAsDataURL(evt.target.files[0]);
      }
    };
  }

  render() {
    if (!('step' in this.props.match.params)) {
      return <Redirect to="/sign-up/1" />;
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
                  onClick={this.goToPreviousStep}
                  title={`Go back to Step ${this.state.currentStep - 1}`}
                >
                  &lt;
                </PreviousStep>
              </Col>
            </Row>
            {this.getStepComponent()}
          </Grid>
        </Sidebar>
        <UserProfile>
          <UserProfileImage
            title="Click to upload a profile background"
            backgroundImage={this.state.user.profileImage}
          >
            <FileInput
              onChange={this.setUserImage('profileImage')}
              type="file"
            />
            {!this.state.user.profileImage ? (
              <div
                style={{
                  position: 'relative',
                  top: '-20px',
                  textAlign: 'center'
                }}
              >
                <FontAwesomeIcon icon={faImage} />
                <P
                  style={{
                    marginTop: '-12px',
                    fontSize: '.8rem',
                    textShadow: '1px 1px 0 lightgrey'
                  }}
                >
                  Click to upload
                  <br />a profile background
                </P>
              </div>
            ) : null}
          </UserProfileImage>
          <UserAvatar
            title="Click to upload your profile image"
            backgroundImage={this.state.user.avatarImage}
          >
            <FileInput
              onChange={this.setUserImage('avatarImage')}
              type="file"
            />
            {!this.state.user.avatarImage ? (
              <FontAwesomeIcon icon={faUser} />
            ) : null}
          </UserAvatar>
          <UserDetails>
            <H6>{this.state.user.emojiId}</H6>
            <H6>
              <FadedFallbackText
                value={this.state.user.username}
                fallback="joebloggs84"
              />
            </H6>
            <H6>
              <FadedFallbackText
                value={this.state.user.role}
                fallback="Head Teacher"
              />
              <span style={{ color: 'lightgrey' }}>&nbsp;—&nbsp;</span>
              <FadedFallbackText
                value={this.state.user.location}
                fallback="London, UK"
              />
            </H6>
          </UserDetails>
          {this.state.currentStep > 1 ? (
            <Interests interests={this.state.user.interests} />
          ) : null}
          {this.state.currentStep > 1 ? (
            <Languages languages={this.state.user.languages} />
          ) : null}
        </UserProfile>
      </SignUpBody>
    );
  }
}
