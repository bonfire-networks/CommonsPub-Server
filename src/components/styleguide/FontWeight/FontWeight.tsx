import * as React from 'react';

import styled, { withTheme, ThemeInterface } from '../../../themes/styled';

interface ColourBlockProps {
  theme: ThemeInterface;
  colour: string;
}

const FontWeight = styled.div`
  float: left;
  colour: white;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 20px 0 0;
  background-color: ${(props: ColourBlockProps) =>
    props.theme.styles.colour[props.colour]};
`;

export default withTheme<{ theme: ThemeInterface; weight: string }>(
  ({ theme, weight }) => {
    const fontWeight = theme.styles.fontWeight[weight];
    const uppercaseWeight =
      weight.substr(0, 1).toUpperCase() + weight.substr(1);
    return (
      <FontWeight>
        <div style={{ fontWeight }}>Open Sans {uppercaseWeight}</div>
      </FontWeight>
    );
  }
);
