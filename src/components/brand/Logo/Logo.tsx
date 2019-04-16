import * as React from 'react';
// import media from 'styled-media-query';
import styled from '../../../themes/styled';
import { Link } from 'react-router-dom';
const LogoImg = require('../../../static/img/moodlenet-logo-white.png');

const LogoH1 = styled.h1<{ big?: boolean }>`
  margin: 0;
  line-height: 32px;

  color: ${props =>
    props.big
      ? props.theme.styles.colour.primary
      : props.theme.styles.colour.logo};

  margin-bottom: ${props => (props.big ? '8px' : '24px')};

  & a {
    color: inherit !important;
    text-decoration: none;
  }
  & img {
    height: ${props => (props.big ? '62px' : '26px')};
    width: auto;
  }
`;

type LogoProps = {
  link?: boolean;
  big?: boolean;
};

/**
 * MoodleNet Logo component.
 * @param link {Boolean} wrap Logo component in a Link to the homepage
 */
export default ({ link = true, big }: LogoProps) => {
  return (
    <>
      <LogoH1 big={big}>
        <Link to="/" title="MoodleNet">
          <img src={LogoImg} alt="MoodleNet" />
        </Link>
      </LogoH1>
    </>
  );
};
