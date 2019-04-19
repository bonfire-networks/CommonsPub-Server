import * as React from 'react';
// import media from 'styled-media-query';
import styled from '../../../themes/styled';
import { Link } from 'react-router-dom';
import { useTheme } from '../../../styleguide/Wrapper';

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
    display: block;
    line-height: 42px;
  }
  & img {
    height: ${props => (props.big ? '62px' : '18px')};
    width: auto;
  }
`;

type LogoProps = {
  link?: boolean;
  big?: boolean;
};

function getLogo() {
  const themeState = useTheme();

  return require(`../../../static/img/${
    themeState.dark ? 'moodlenet-logo-white' : 'moodlenet-logo-grey'
  }.png`);
}

/**
 * MoodleNet Logo component.
 * @param link {Boolean} wrap Logo component in a Link to the homepage
 */
export default ({ link = true, big }: LogoProps) => {
  return (
    <>
      <LogoH1 big={big}>
        <Link to="/" title="MoodleNet">
          <img src={getLogo()} alt="MoodleNet" />
        </Link>
      </LogoH1>
    </>
  );
};
