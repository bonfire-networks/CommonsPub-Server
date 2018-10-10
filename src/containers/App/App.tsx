import * as React from 'react';
import '@zendeskgarden/react-chrome/dist/styles.css';
import '@zendeskgarden/react-grid/dist/styles.css';
import '@zendeskgarden/react-buttons/dist/styles.css';
import '@zendeskgarden/react-menus/dist/styles.css';
import '@zendeskgarden/react-avatars/dist/styles.css';
import '@zendeskgarden/react-textfields/dist/styles.css';
import '@zendeskgarden/react-tags/dist/styles.css';

import Nav from '../../components/chrome/Nav/Nav';
import CommunitiesFeatured from '../../pages/communities.featured/CommunitiesFeatured';
import Menu from '../../components/chrome/Menu/Menu';
import styled from '../../themes/styled';
import { moodlenet } from '../../themes';
const { ThemeProvider } = require('@zendeskgarden/react-theming');
const { Chrome, Body } = require('@zendeskgarden/react-chrome');

export const AppStyles = styled.div`
  font-family: ${props => props.theme.styles.fontFamily};
`;

export default class App extends React.Component {
  render() {
    return (
      <ThemeProvider theme={moodlenet}>
        <AppStyles>
          <Chrome>
            <Nav />
            <Body>
              <Menu />
              <CommunitiesFeatured />
            </Body>
          </Chrome>
        </AppStyles>
      </ThemeProvider>
    );
  }
}
