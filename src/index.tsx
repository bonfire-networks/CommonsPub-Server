import * as React from 'react';
import ReactDOM from 'react-dom';
import { ApolloProvider } from 'react-apollo';

import getApolloClient from './apollo/client';
import registerServiceWorker from './registerServiceWorker';
import App from './containers/App/App';
import { injectGlobal } from './themes/styled';

run();

async function run() {
  const apolloClient = await getApolloClient();

  injectGlobal`
      body, html {
          border: 0;
          margin: 0;
          padding: 0;
          width: 100%;
          height: 100%;
      }
      
      * {
        box-sizing: border-box;
      }
  `;

  const ApolloApp = () => (
    <ApolloProvider client={apolloClient}>
      <App />
    </ApolloProvider>
  );

  ReactDOM.render(<ApolloApp />, document.getElementById('root'));

  registerServiceWorker();
}
