const { getUserQuery } = require('../../graphql/getUser.client.graphql');

export default function setUser(_, { isAuthenticated, data }, { cache }) {
  const previousState = cache.readQuery({
    query: getUserQuery
  });

  const cacheData = {
    user: {
      ...previousState.user,
      isAuthenticated,
      data
    }
  };

  cache.writeQuery({
    query: getUserQuery,
    data: cacheData
  });

  return null;
}
