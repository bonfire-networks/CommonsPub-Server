import * as React from 'react';
import '@zendeskgarden/react-chrome/dist/styles.css';
import '@zendeskgarden/react-grid/dist/styles.css';
import '@zendeskgarden/react-buttons/dist/styles.css';
import '@zendeskgarden/react-menus/dist/styles.css';
import '@zendeskgarden/react-avatars/dist/styles.css';
import '../../../App.css';

const { ThemeProvider } = require('@zendeskgarden/react-theming');
const { Chrome, Body } = require('@zendeskgarden/react-chrome');
const { Nav } = require('../Nav/Nav');
const { Menu } = require('../Menu/Menu');
const {
  CommunitiesFeatured
} = require('../../../pages/communities.featured/CommunitiesFeatured');
const { theme } = require('../../../theme');

export class App extends React.Component {
  render() {
    return (
      <ThemeProvider theme={theme}>
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
