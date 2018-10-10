import * as React from 'react';
import { moodlenet } from '../themes';

const { ThemeProvider } = require('@zendeskgarden/react-theming');
import { AppStyles } from '../containers/App/App';

/**
 * Used in `styleguide.config.js` to pass through the MoodleNet theme
 * to components in the style guide.
 */
export default class Wrapper extends React.Component {
  render() {
    return (
      <ThemeProvider theme={moodlenet}>
        <AppStyles>{this.props.children}</AppStyles>
      </ThemeProvider>
    );
  }
}
