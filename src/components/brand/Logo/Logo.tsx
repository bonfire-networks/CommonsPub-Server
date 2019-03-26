import * as React from 'react';

import styled from '../../../themes/styled';
import { Link } from 'react-router-dom';

const LogoH1 = styled.h1<{ big?: boolean }>`
  margin: 0;
  font-size: ${props => (props.big ? '28px' : '14px')};
  line-height: 32px;
  color: ${props => props.theme.styles.colour.primary};
  letter-spacing: 1px;
  margin-bottom: ${props => (props.big ? '8px' : '24px')};

  & a {
    color: ${props => props.theme.styles.colour.primary};
    text-decoration: none;
  }
`;

const Small = styled.a<{ big?: boolean }>`
  margin-left: 4px;
  padding: 4px 8px;
  border-radius: 4px;
  background: ${props => props.theme.styles.colour.primary};
  color: white !important;
  font-weight: 600 !important;
  letter-spacing: 0.5px;
  font-size: 11px;
  text-transform: uppercase;
  cursor: pointer;
  text-decoration: none;
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
          MoodleNet
        </Link>
        {big ? null : (
          <Small
            href="https://blog.moodle.net/2019/moodlenet-0-7-alpha-update/"
            target="blank"
            big={big}
          >
            <small>v 0.7 alpha</small>
          </Small>
        )}
      </LogoH1>
      {big ? (
        <Small
          href="https://blog.moodle.net/2019/moodlenet-0-7-alpha-update/"
          target="blank"
          big={big}
        >
          <small>v 0.7 alpha</small>
        </Small>
      ) : null}
    </>
  );
};
