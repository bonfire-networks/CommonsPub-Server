import * as React from 'react';
import { graphql } from 'react-apollo';
import { Route, Redirect, RouteComponentProps } from 'react-router-dom';

const { GetUserQuery } = require('../../graphql/GET_USER.client.graphql');

interface ProtectedRouteProps extends RouteComponentProps {
  redirectUnauthenticatedTo?: string;
}

function ProtectedRoute({ component: Component, data, ...rest }) {
  return (
    <Route
      {...rest}
      render={(props: ProtectedRouteProps) => {
        // TODO reinstate after dev
        // if (data.user.isAuthenticated) {
        return <Component {...props} />;
        // }
        return (
          <Redirect
            to={{
              pathname: props.redirectUnauthenticatedTo || '/login',
              state: { from: props.location }
            }}
          />
        );
      }}
    />
  );
}

const WrappedComponent = graphql(GetUserQuery)(ProtectedRoute);

export default function({ ...props }) {
  return <WrappedComponent {...props} />;
}
