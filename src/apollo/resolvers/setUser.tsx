const { getUserQuery } = require('../../graphql/getUser.client.graphql');

/**
 * Set the user in the local state.
 * @param _
 * @param isAuthenticated {Boolean} is user authenticated (if yes, expect `data`)
 * @param [data] {Object} user data, if authenticated
 * @param cache {Object} the Apollo cache
 */
export default function setUser(_, { isAuthenticated, data }, { cache }) {
  const cacheData = {
    user: {
      __typename: 'User',
      isAuthenticated
      // data
    }
  };

  cache.writeQuery({
    query: getUserQuery,
    data: cacheData
  });

  return null;
}
