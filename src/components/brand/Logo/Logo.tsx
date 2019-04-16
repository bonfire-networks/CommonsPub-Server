import * as React from 'react';
import media from 'styled-media-query';
import styled from '../../../themes/styled';
import { Link } from 'react-router-dom';
const LogoImg = require('../../../static/img/moodlenet-logo-white.png');

const LogoH1 = styled.h1<{ big?: boolean }>`
  margin: 0;
  font-size: ${props => (props.big ? '28px' : '14px')};
  line-height: 32px;
  color: ${props =>
    props.big
      ? props.theme.styles.colour.primary
      : props.theme.styles.colour.logo};
  letter-spacing: 1px;
  margin-bottom: ${props => (props.big ? '8px' : '24px')};

  & a {
    color: inherit !important;
    text-decoration: none;
    display: inline-block;
    margin-top: 8px;
  }
  & img {
    height: 26px;
    width: auto;
  }
`;

const Small = styled.a<{ big?: boolean }>`
  color: ${props => props.theme.styles.colour.headerLink} !important;
  font-weight: 400 !important;
  letter-spacing: 0.5px;
  font-size: 11px;
  line-height: auto;
  vertical-align: top;
  // text-transform: uppercase;
  cursor: pointer;
  text-decoration: none;
  margin-left: 16px;
  ${media.lessThan('medium')`
    display: none;
    `};
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
        {big ? null : (
          <Small
            href="https://blog.moodle.net/2019/moodlenet-0-9-alpha-update/"
            target="blank"
            big={big}
          >
            <small>0.9.1 alpha</small>
          </Small>
        )}
      </LogoH1>
      {big ? (
        <Small
          href="https://blog.moodle.net/2019/moodlenet-0-9-alpha-update/"
          target="blank"
          big={big}
        >
          <small>0.9.1 alpha</small>
        </Small>
      ) : null}
    </>
  );
};
