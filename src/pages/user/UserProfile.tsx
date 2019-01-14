import * as React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faImage, faUser } from '@fortawesome/free-solid-svg-icons';

import { Trans } from '@lingui/macro';

import P from '../../components/typography/P/P';
import H6 from '../../components/typography/H6/H6';
import styled, { StyledThemeInterface } from '../../themes/styled';
import User from '../../types/User';

const FileInput = styled.input`
  cursor: pointer;
  height: calc(100% + 100px);
  width: 100%;
  position: absolute;
  top: -100px;
  left: 0;

  &:focus {
    outline: 0;
  }
`;

//TODO media queries/responsivity
export const UserProfile = styled.div`
  overflow: auto;
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
      ? `linear-gradient(transparent, rgba(0, 0, 0, .75)), url(${
          props.backgroundImage
        })`
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

const AvatarPlaceholder = styled.div`
  font-size: 12px;
  position: absolute;
  top: 150px;
  text-align: center;
  text-shadow: 1px 1px 0 #00000069;
  transition: all 0.2s linear;
`;

//TODO don't use the `any` props type
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

  // avatar placeholder
  > div {
    font-size: 6px;
    pointer-events: none;
  }

  &:hover > div {
    top: 50%;
    font-size: 12px;
  }
  // end avatar placeholder

  // avatar font awesome icon
  svg {
    top: 0;
    position: relative;
    transition: all 0.2s linear;
    pointer-events: none;
  }

  &:hover svg {
    font-size: 30px;
    top: -25px;
  }
  // end avatar font awesome icon
`;

const UserDetails = styled.div`
  position: relative;
  top: ${liftUserAvatar}px;
  text-align: center;
`;

const FadedFallbackText = ({ value, fallback }) =>
  value ? (
    <span>{value}</span>
  ) : (
    <span style={{ color: 'lightgrey' }}>{fallback}</span>
  );

// the body of UserProfile is customisable through a render prop
// the `body` render prop will be passed this style object which
// should be passed to the container returned from the render prop
const bodyProps = {
  style: {
    position: 'relative',
    top: `${liftUserAvatar}px`
  }
};

type UserProfileProps = {
  innerRef: (instance: any) => void;
  user: User;
  setUserImage: Function; // TODO make this optional
  body?: ({ containerProps: object }) => JSX.Element;
};

export default function(props: UserProfileProps) {
  return (
    <UserProfile innerRef={props.innerRef}>
      <UserProfileImage backgroundImage={props.user.profileImage}>
        <FileInput onChange={props.setUserImage('profileImage')} type="file" />
        {!props.user.profileImage ? (
          <div
            style={{
              pointerEvents: 'none',
              position: 'relative',
              top: '-20px',
              textAlign: 'center'
            }}
          >
            <FontAwesomeIcon icon={faImage} />
            <P
              style={{
                pointerEvents: 'none',
                marginTop: '-12px',
                fontSize: '.8rem',
                textShadow: '1px 1px 0 lightgrey'
              }}
            >
              <Trans>Click to select a profile background</Trans>
            </P>
          </div>
        ) : null}
      </UserProfileImage>
      <UserAvatar backgroundImage={props.user.avatarImage}>
        <FileInput onChange={props.setUserImage('avatarImage')} type="file" />
        {!props.user.avatarImage ? (
          <>
            <FontAwesomeIcon icon={faUser} />
            <AvatarPlaceholder>
              <Trans>Click to select a profile picture</Trans>
            </AvatarPlaceholder>
          </>
        ) : null}
      </UserAvatar>
      <UserDetails>
        <H6>{props.user.preferredUsername}</H6>
        <H6>
          <FadedFallbackText value={props.user.name} fallback="Moodler Joe" />
        </H6>
        <H6>
          {/*<FadedFallbackText value={props.user.role} fallback="Head Teacher" />*/}
          {/*<span style={{ color: 'lightgrey' }}>&nbsp;—&nbsp;</span>*/}
          <FadedFallbackText
            value={props.user.location}
            fallback="London, UK"
          />
        </H6>
      </UserDetails>
      {props.body ? props.body({ containerProps: bodyProps }) : null}
      {/*padding forces profile to be scrollable*/}
      <div style={{ height: '75%', width: '100%' }} />
    </UserProfile>
  );
}
