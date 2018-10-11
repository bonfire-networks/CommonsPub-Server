const { GetUserQuery } = require('../../graphql/GET_USER.client.graphql');

export default (_, { isAuthenticated, data }, { cache }) => {
  const previousState = cache.readQuery({
    query: GetUserQuery
  });

  const cacheData = {
    user: {
      ...previousState.user,
      isAuthenticated,
      data
    }
  };

  cache.writeQuery({
    query: GetUserQuery,
    data: cacheData
  });

  return null;
};
