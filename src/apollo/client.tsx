import { ApolloLink } from 'apollo-link';
import { ApolloClient } from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { setContext } from 'apollo-link-context';
import { withClientState } from 'apollo-link-state';
import { createAbsintheSocketLink } from '@absinthe/socket-apollo-link';
import { Socket as PhoenixSocket } from 'phoenix';
import { createHttpLink } from 'apollo-link-http';
import { hasSubscription } from '@jumpn/utils-graphql';
import * as AbsintheSocket from '@absinthe/socket';

import resolvers from './resolvers';
import typeDefs from './typeDefs';
import { GRAPHQL_ENDPOINT, PHOENIX_SOCKET_ENDPOINT } from '../constants';

const cache = new InMemoryCache();

const token = localStorage.getItem('user_access_token');

const defaults = {
  user: {
    __typename: 'User',
    isAuthenticated: token ? token : false,
    data: null // TODO get user if already authenticated
  }
};

const stateLink = withClientState({
  cache,
  resolvers,
  defaults,
  typeDefs
});

const authLink = setContext((_, { headers }) => {
  // get the authentication token from localstorage if it exists
  const token = localStorage.getItem('user_access_token');
  // return the headers to the context so httpLink can read them
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : null
    }
  };
});

// used for graphql query and mutations
const httpLink = ApolloLink.from([
  stateLink,
  authLink,
  createHttpLink({ uri: GRAPHQL_ENDPOINT })
]);

// used for graphql subscriptions
const absintheSocket = createAbsintheSocketLink(
  AbsintheSocket.create(new PhoenixSocket(PHOENIX_SOCKET_ENDPOINT))
);

// if the operation is a subscription then use
// the absintheSocket otherwise use the httpLink
const link = ApolloLink.split(
  operation => hasSubscription(operation.query),
  absintheSocket,
  httpLink
);

export default new ApolloClient({
  cache,
  link
});
