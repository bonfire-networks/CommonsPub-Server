import * as React from 'react';
import { graphql } from 'react-apollo';
import { Route, Redirect, RouteComponentProps } from 'react-router-dom';

const { getUserQuery } = require('../../graphql/getUser.client.graphql');

interface ProtectedRouteProps extends RouteComponentProps {
  redirectUnauthenticatedTo?: string;
}

/**
 * ProtectedRoute component.
 * This hooks into the local apollo graphql state and checks if a user
 * is present and authenticated in the state. If yes it allows navigation
 * to the route, otherwise it redirects the user to the login page or other
 * page defined in `props.redirectUnauthenticatedTo`.
 * @param Component {JSX.Element} the page element that requires authentication to access
 * @param data {Object} result of graphql local state query
 * @param rest {Object} props or the Route component
 * @constructor
 */
function ProtectedRoute({ component: Component, data, ...rest }) {
  let token;
  process.env.REACT_APP_GRAPHQL_ENDPOINT ===
  'https://home.moodle.net/api/graphql'
    ? (token = localStorage.getItem('user_access_token'))
    : (token = localStorage.getItem('dev_user_access_token'));

  return (
    <Route
      {...rest}
      render={(props: ProtectedRouteProps) => {
        if (token) {
          return <Component {...props} />;
        }
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

const WrappedComponent = graphql(getUserQuery)(ProtectedRoute);

export default function({ ...props }) {
  return <WrappedComponent {...props} />;
}
