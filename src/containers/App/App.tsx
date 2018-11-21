import * as React from 'react';
import { ApolloProvider } from 'react-apollo';
import { Catalogs } from '@lingui/core';

import styled from '../../themes/styled';
import Router from './Router';
import apolloClient from '../../apollo/client';
import { moodlenet } from '../../themes';
import { ThemeProvider } from '@zendeskgarden/react-theming';
import { Chrome } from '@zendeskgarden/react-chrome';
import { I18nProvider } from '@lingui/react';

import '@zendeskgarden/react-chrome/dist/styles.css';
import '@zendeskgarden/react-grid/dist/styles.css';
import '@zendeskgarden/react-buttons/dist/styles.css';
import '@zendeskgarden/react-menus/dist/styles.css';
import '@zendeskgarden/react-avatars/dist/styles.css';
import '@zendeskgarden/react-textfields/dist/styles.css';
import '@zendeskgarden/react-tags/dist/styles.css';
import '@zendeskgarden/react-select/dist/styles.css';
import '@zendeskgarden/react-checkboxes/dist/styles.css';
import '@zendeskgarden/react-pagination/dist/styles.css';
import '@zendeskgarden/react-tabs/dist/styles.css';
import '@zendeskgarden/react-tooltips/dist/styles.css';

import '../../styles/social-icons.css';
import '../../styles/flag-icons.css';
import '../../styles/loader.css';

export const AppStyles = styled.div`
  font-family: ${props => props.theme.styles.fontFamily};

  * {
    font-family: ${props => props.theme.styles.fontFamily};
  }
`;

export const LocaleContext = React.createContext({
  catalogs: {},
  locale: 'en',
  setLocale: locale => {}
});

type AppState = {
  catalogs: Catalogs;
  locale: string;
  setLocale: (locale) => void;
};

export default class App extends React.Component<{}, AppState> {
  state = {
    catalogs: {
      en: require(process.env.NODE_ENV === 'development'
        ? '../../locales/en/messages.json'
        : '../../locales/en/messages.js')
    },
    locale: 'en',
    setLocale: this.setLocale.bind(this)
  };

  async setLocale(locale) {
    let catalogs = {};

    if (!this.state.catalogs[locale]) {
      let catalog;

      if (process.env.NODE_ENV === 'development') {
        catalog = await import(/* webpackMode: "lazy", webpackChunkName: "i18n-[index]" */
        `@lingui/loader!../../locales/${locale}/messages.json`);
      } else {
        catalog = await import(/* webpackMode: "lazy", webpackChunkName: "i18n-[index]" */
        `../../locales/${locale}/messages.js`);
      }

      catalogs = {
        ...this.state.catalogs,
        [locale]: catalog
      };
    }

    this.setState({
      locale,
      catalogs
    });
  }

  render() {
    if (!this.state.catalogs[this.state.locale]) {
      return (
        <p>Sorry, we encountered a problem loading the chosen language.</p>
      );
    }

    return (
      <ApolloProvider client={apolloClient}>
        <ThemeProvider theme={moodlenet}>
          <LocaleContext.Provider value={this.state}>
            <I18nProvider
              language={this.state.locale}
              catalogs={this.state.catalogs}
            >
              <AppStyles>
                <Chrome>
                  <Router />
                </Chrome>
              </AppStyles>
            </I18nProvider>
          </LocaleContext.Provider>
        </ThemeProvider>
      </ApolloProvider>
    );
  }
}
