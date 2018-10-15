import * as React from 'react';
import Loadable from 'react-loadable';
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom';

import styled from '../../themes/styled';
import Home from '../../pages/home/Home';
import Login from '../../pages/login/Login';
import NotFound from '../../pages/not-found/NotFound';
import ProtectedRoute from './ProtectedRoute';
import Loader from '../../components/elements/Loader/Loader';

const AppInner = styled.div`
  display: flex;
  flex-direction: row;
  width: 100%;
  height: 100%;
`;

const SignUp = Loadable({
  loader: () => import('../../pages/sign-up/SignUp'),
  loading: () => <Loader />,
  delay: 300
});

export default () => (
  <Router>
    <AppInner>
      <Switch>
        <ProtectedRoute exact path="/" component={Home} />
        <Route exact path="/login" component={Login} />
        <Route exact path="/sign-up" component={SignUp} />
        <Route exact path="/sign-up/:step([1-9])" component={SignUp} />
        <Route component={NotFound} />
      </Switch>
    </AppInner>
  </Router>
);
