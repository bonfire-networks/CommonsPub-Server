import * as React from 'react';

import styled from '../../../themes/styled';
import { Link } from 'react-router-dom';

const LogoH1 = styled.h1`
  margin: 0;
  font-size: 14px;
  line-height: 32px;
  color: ${props => props.theme.styles.colour.primary};
  letter-spacing: 1px;
  margin-bottom: 24px;
  & a {
    color: ${props => props.theme.styles.colour.primary};
    text-decoration: none;
  }
  & small {
    letter-spacing: 0;
    color: #151b2680;
    font-weight: 600;
    font-style: italic;
  }
`;

type LogoProps = {
  link?: boolean;
};

/**
 * MoodleNet Logo component.
 * @param link {Boolean} wrap Logo component in a Link to the homepage
 */
export default ({ link = true }: LogoProps) => {
  return (
    <LogoH1>
      <Link to="/" title="MoodleNet">
        MoodleNet <small>v0.5</small>
      </Link>
    </LogoH1>
  );
};
