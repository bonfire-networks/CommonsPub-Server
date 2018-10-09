import * as React from 'react';
import { moodlenet } from '../themes/themes';

const { ThemeProvider } = require('@zendeskgarden/react-theming');

export default class Wrapper extends React.Component {
  render() {
    return (
      <ThemeProvider theme={moodlenet}>{this.props.children}</ThemeProvider>
    );
  }
}
