import * as React from 'react';
import '@zendeskgarden/react-chrome/dist/styles.css';
import '@zendeskgarden/react-grid/dist/styles.css';
import '@zendeskgarden/react-buttons/dist/styles.css';
import '@zendeskgarden/react-menus/dist/styles.css';
import '@zendeskgarden/react-avatars/dist/styles.css';

import Nav from '../Nav/Nav';
import CommunitiesFeatured from '../../../pages/communities.featured/CommunitiesFeatured';
import Menu from '../Menu/Menu';
import { moodlenet } from '../../../themes/themes';
const { ThemeProvider } = require('@zendeskgarden/react-theming');
const { Chrome, Body } = require('@zendeskgarden/react-chrome');

export default class App extends React.Component {
  render() {
    return (
      <ThemeProvider theme={moodlenet}>
        <Chrome className="App">
          <Nav />
          <Body className="Body">
            <Menu />
            <CommunitiesFeatured />
          </Body>
        </Chrome>
      </ThemeProvider>
    );
  }
}
