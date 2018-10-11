import ApolloClient from 'apollo-boost';

import resolvers from './resolvers';

export default new ApolloClient({
  clientState: {
    defaults: {
      user: {
        __typename: 'User',
        isAuthenticated: false,
        data: null
      }
    },
    resolvers
  }
});
