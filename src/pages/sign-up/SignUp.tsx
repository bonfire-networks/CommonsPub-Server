import * as React from 'react';
import { Redirect, RouteComponentProps } from 'react-router';
import { Grid, Row, Col } from '@zendeskgarden/react-grid';

import styled, { StyledThemeInterface } from '../../themes/styled';
import Logo from '../../components/brand/Logo/Logo';
import Body from '../../components/chrome/Body/Body';
import PreviousStep from './PreviousStep';
import Tag, { TagContainer } from '../../components/elements/Tag/Tag';
import Step1 from './Step1';
import Step2 from './Step2';
import UserProfile from '../user/UserProfile';
import User from '../../types/User';
import H4 from '../../components/typography/H4/H4';
import Button from '../../components/elements/Button/Button';

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
  2: 650
};

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
  user: User;
}

interface SignUpProps extends RouteComponentProps<SignUpMatchParams> {}

const SignUpProfileSection = styled.div<any>`
  padding: 50px;
`;

const Step2Section = styled.div<any>`
  opacity: ${props => (props.active ? 1 : 0.1)};
  pointer-events: ${props => (props.active ? 'unset' : 'none')};
  transition: opacity 1.75s linear;
`;

const Interests = ({ active, interests, onTagClick }) => (
  <Step2Section active={active}>
    <H4>Interests</H4>
    <TagContainer>
      {interests.map(interest => (
        <Tag
          focused
          closeable
          key={interest}
          onClick={() => onTagClick(interest)}
        >
          {interest}
        </Tag>
      ))}
    </TagContainer>
  </Step2Section>
);

const Languages = ({ active, languages }) => (
  <Step2Section active={active}>
    <H4>Languages</H4>
  </Step2Section>
);

export default class SignUp extends React.Component<SignUpProps, SignUpState> {
  static stepComponents = [Step1, Step2];

  _profileElem: HTMLElement;

  state = {
    currentStep: -1,
    user: {
      username: '',
      email: '',
      emojiId: generateEmojiId(),
      avatarImage: undefined,
      profileImage: undefined,
      role: '',
      location: '',
      language: 'en-gb',
      interests: [] as string[],
      languages: [] as string[]
    } as User
  };

  constructor(props) {
    super(props);

    this.state.currentStep = Number(props.match.params.step);

    if (!this.state.user.username && this.state.currentStep > 1) {
      this.props.history.replace('/sign-up');
      return;
    }

    this.randomizeEmojiId = this.randomizeEmojiId.bind(this);
    this.linkUserState = this.linkUserState.bind(this);
    this.goToNextStep = this.goToNextStep.bind(this);
    this.goToPreviousStep = this.goToPreviousStep.bind(this);
    this.toggleUserInterest = this.toggleUserInterest.bind(this);
    this.setUserImage = this.setUserImage.bind(this);
  }

  componentWillReceiveProps(nextProps) {
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
          goToNextStep: this.goToNextStep,
          goToPreviousStep: this.goToPreviousStep,
          randomizeEmojiId: this.randomizeEmojiId,
          linkUserState: this.linkUserState,
          toggleInterest: this.toggleUserInterest
        }}
      />
    );
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
      this.scrollForStep(prevStep);
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
    this.scrollForStep(nextStep);
  }

  scrollForStep(step) {
    // https://gist.github.com/andjosh/6764939#gistcomment-2047675
    function scrollTo(element, to = 0, duration = 1000) {
      if (!element) {
        return;
      }
      const start = element.scrollTop;
      const change = to - start;
      const increment = 20;
      let currentTime = 0;
      const animateScroll = () => {
        currentTime += increment;
        element.scrollTop = easeInOutQuad(currentTime, start, change, duration);
        if (currentTime < duration) {
          setTimeout(animateScroll, increment);
        }
      };
      animateScroll();
    }
    function easeInOutQuad(t, b, c, d) {
      t /= d / 2;
      if (t < 1) return (c / 2) * t * t + b;
      t--;
      return (-c / 2) * (t * (t - 2) - 1) + b;
    }
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
   * Load an image from the user file system and set as `imageTypeName` on the
   * state so it can be displayed without uploading.
   * @param imageTypeName the type of image being set
   */
  setUserImage(
    imageTypeName: 'profileImage' | 'avatarImage'
  ): (evt: React.SyntheticEvent) => void {
    return (evt: any) => {
      const reader = new FileReader();

      reader.addEventListener(
        'load',
        () => {
          this.setState({
            user: {
              ...this.state.user,
              [imageTypeName]: reader.result as string
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

  private getNextStepName() {
    return ['your interests', 'discover'][this.state.currentStep - 1];
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
            <Row style={{ flexGrow: 1 }} />
            <Row>
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
                    <Button secondary onClick={this.goToNextStep}>
                      Skip
                    </Button>
                    <div style={{ height: '10px', width: '10px' }} />
                  </>
                ) : null}
                <Button onClick={this.goToNextStep}>Continue</Button>
              </Col>
            </Row>
          </Grid>
        </Sidebar>
        <UserProfile
          innerRef={e => (this._profileElem = e)}
          user={this.state.user}
          setUserImage={this.setUserImage}
          body={({ containerProps }) => {
            return (
              <SignUpProfileSection {...containerProps}>
                <Interests
                  onTagClick={this.toggleUserInterest}
                  active={this.state.currentStep > 1}
                  interests={this.state.user.interests}
                />
                <Languages
                  active={this.state.currentStep > 1}
                  languages={this.state.user.languages}
                />
              </SignUpProfileSection>
            );
          }}
        />
      </SignUpBody>
    );
  }
}
