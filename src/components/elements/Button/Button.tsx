import * as React from 'react';

const { ThemeProvider } = require('@zendeskgarden/react-theming');
const { Button } = require('@zendeskgarden/react-buttons');

const { defaultTheme } = require('../../../theme');

const theme = {
  'buttons.button': `
        background-color: '${defaultTheme.primaryColor}';
        color: white;
    `
};

export const MoodleButton = ({ children }) => {
  return (
    <ThemeProvider theme={theme}>
      <Button>{children}</Button>
    </ThemeProvider>
  );
};
