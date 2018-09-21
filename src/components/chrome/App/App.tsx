import * as React from 'react';
const { Chrome, Body } = require('@zendeskgarden/react-chrome');

const { Nav } = require('../Nav/Nav');
const { Menu } = require('../Menu/Menu');
const {
  CommunitiesFeatured
} = require('../../../pages/communities.featured/CommunitiesFeatured');

import '@zendeskgarden/react-chrome/dist/styles.css';
import '@zendeskgarden/react-grid/dist/styles.css';
import '@zendeskgarden/react-buttons/dist/styles.css';
import '@zendeskgarden/react-menus/dist/styles.css';
import '@zendeskgarden/react-avatars/dist/styles.css';
import '../../../App.css';

export class App extends React.Component {
  render() {
    return (
      <Chrome className="App">
        <Nav />
        <Body className="Body">
          <Menu />
          <CommunitiesFeatured />
        </Body>
      </Chrome>
    );
  }
}
