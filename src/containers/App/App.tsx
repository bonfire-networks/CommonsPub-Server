import * as React from 'react';
import { ApolloProvider } from 'react-apollo';

import styled from '../../themes/styled';
import Router from './Router';
import apolloClient from '../../apollo/client';
import { moodlenet } from '../../themes';
import { ThemeProvider } from '@zendeskgarden/react-theming';
import { Chrome } from '@zendeskgarden/react-chrome';

import '@zendeskgarden/react-chrome/dist/styles.css';
import '@zendeskgarden/react-grid/dist/styles.css';
import '@zendeskgarden/react-buttons/dist/styles.css';
import '@zendeskgarden/react-menus/dist/styles.css';
import '@zendeskgarden/react-avatars/dist/styles.css';
import '@zendeskgarden/react-textfields/dist/styles.css';
import '@zendeskgarden/react-tags/dist/styles.css';
import '@zendeskgarden/react-select/dist/styles.css';

import '../../styles/social-icons.css';
import '../../styles/flag-icons.css';
import '../../styles/loader.css';

export const AppStyles = styled.div`
  font-family: ${props => props.theme.styles.fontFamily};
`;

export default class App extends React.Component {
  render() {
    return (
      <ApolloProvider client={apolloClient}>
        <ThemeProvider theme={moodlenet}>
          <AppStyles>
            <Chrome>
              <Router />
            </Chrome>
          </AppStyles>
        </ThemeProvider>
      </ApolloProvider>
    );
  }
}
