import * as React from 'react';

import styled from '../../../themes/styled';
import { Link } from 'react-router-dom';

const moodleNetLogo = require('../../../static/img/moodlenet-logo.png');

const LogoH1 = styled.h1`
  margin: 0;
`;

export default () => (
  <LogoH1>
    <Link to="/" title="MoodleNet">
      <img src={moodleNetLogo} alt="MoodleNet" />
    </Link>
  </LogoH1>
);
