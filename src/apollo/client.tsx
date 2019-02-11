import { ApolloLink } from 'apollo-link';
import { ApolloClient, ApolloQueryResult } from 'apollo-client';
import {
  InMemoryCache,
  IntrospectionFragmentMatcher
} from 'apollo-cache-inmemory';
import { setContext } from 'apollo-link-context';
import { withClientState } from 'apollo-link-state';
import { createAbsintheSocketLink } from '@absinthe/socket-apollo-link';
import { Socket as PhoenixSocket } from 'phoenix';
import { createHttpLink } from 'apollo-link-http';
import { hasSubscription } from '@jumpn/utils-graphql';
import apolloLogger from 'apollo-link-logger';
import * as AbsintheSocket from '@absinthe/socket';
const introspectionQueryResultData = require('../fragmentTypes.json');
import resolvers from './resolvers';
import typeDefs from './typeDefs';
import { GRAPHQL_ENDPOINT, PHOENIX_SOCKET_ENDPOINT } from '../constants';

const { meQuery } = require('../graphql/me.graphql');
const { setUserMutation } = require('../graphql/setUser.client.graphql');

const fragmentMatcher = new IntrospectionFragmentMatcher({
  introspectionQueryResultData
});

const cache = new InMemoryCache({ fragmentMatcher });
const token = localStorage.getItem('user_access_token');
const user = localStorage.getItem('user_data');

const defaults = {
  user: {
    __typename: 'User',
    isAuthenticated: !!token,
    data: user ? JSON.parse(user) : null
  }
};

const stateLink = withClientState({
  cache,
  resolvers,
  defaults,
  typeDefs
});

/**
 * This context link is used to assign the necessary Authorization header
 * to all HTTP requests to the GraphQL backend. In the case that the user
 * is authenticated it sets their access token as the value, otherwise null.
 */
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
const httpLink = ApolloLink.from(
  [
    process.env.NODE_ENV === 'development' ? apolloLogger : null,
    stateLink,
    authLink,
    createHttpLink({ uri: GRAPHQL_ENDPOINT })
  ].filter(Boolean)
);

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

const client = new ApolloClient({
  cache,
  link
});

interface MeQueryResult extends ApolloQueryResult<object> {
  // TODO don't use any type
  me: any;
}

/**
 * Initialise the Apollo client by fetching the logged in user
 * if the user has an existing token in local storage.
 * @returns {ApolloClient} the apollo client
 */
export default async function initialise() {
  let localUser;

  try {
    const result = await client.query<MeQueryResult>({
      query: meQuery
    });

    localUser = {
      isAuthenticated: true,
      data: result.data.me
    };
  } catch (err) {
    console.error(err);

    if (err.message.includes('You are not logged in')) {
      localStorage.removeItem('user_access_token');
    } else {
      //TODO handle unknown error / warn user?
    }

    localUser = {
      isAuthenticated: false,
      data: null
    };
  }

  await client.mutate({
    variables: localUser,
    mutation: setUserMutation
  });

  return client;
}
