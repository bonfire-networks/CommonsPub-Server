import ApolloClient from 'apollo-boost';

import resolvers from './resolvers';
import typeDefs from './typeDefs';

export default new ApolloClient({
  clientState: {
    typeDefs,
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
