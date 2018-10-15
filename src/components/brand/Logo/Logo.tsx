import * as React from 'react';

import styled from '../../../themes/styled';
import { Link } from 'react-router-dom';

const moodleNetLogo = require('../../../static/img/moodlenet-logo.png');

const LogoH1 = styled.h1`
  margin: 0;
`;

type LogoProps = {
  link?: boolean;
};

export default ({ link = true }: LogoProps) => {
  let image = <img src={moodleNetLogo} alt="MoodleNet" />;

  if (link) {
    image = (
      <Link to={link ? '/' : '#'} title="MoodleNet">
        {image}
      </Link>
    );
  }

  return <LogoH1>{image}</LogoH1>;
};
