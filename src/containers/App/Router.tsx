import * as React from 'react';
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom';

import styled from '../../themes/styled';
import Home from '../../pages/home/Home';
import Login from '../../pages/login/Login';
import NotFound from '../../pages/not-found/NotFound';
import ProtectedRoute from './ProtectedRoute';

const AppInner = styled.div`
  display: flex;
  flex-direction: row;
  width: 100%;
  height: 100%;
`;

export default () => (
  <Router>
    <AppInner>
      <Switch>
        <ProtectedRoute exact path="/" component={Home} />
        <Route exact path="/login" component={Login} />
        <Route component={NotFound} />
      </Switch>
    </AppInner>
  </Router>
);
