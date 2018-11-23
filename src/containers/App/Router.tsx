import * as React from 'react';
import Loadable from 'react-loadable';
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom';

import styled from '../../themes/styled';
import Menu from '../../components/chrome/Menu/Menu';
import Nav from '../../components/chrome/Nav/Nav';
import CommunitiesFeatured from '../../pages/communities.featured/CommunitiesFeatured';
import CommunitiesYours from '../../pages/communities.yours/CommunitiesYours';
import CommunitiesCommunity from '../../pages/communities.community/CommunitiesCommunity';
// import CollectionsCollection from '../../pages/collections.collection/CollectionsCollection';
import ResourcesResource from '../../pages/resources.resource/ResourcesResource';
import Login from '../../pages/login/Login';
import NotFound from '../../pages/not-found/NotFound';
import ProtectedRoute from './ProtectedRoute';
import Loader from '../../components/elements/Loader/Loader';
import Search from '../../pages/search/Search';

const AppInner = styled.div`
  display: flex;
  flex-direction: row;
  width: 100%;
  height: 100%;
`;

const CenteredLoader = () => (
  <Loader
    style={{
      transform: 'translate(-50%, -50%)',
      top: '50%',
      left: '50%',
      position: 'fixed'
    }}
  />
);

const SignUp = Loadable({
  loader: () => import('../../pages/sign-up/SignUp'),
  loading: () => <CenteredLoader />,
  delay: 1000
});

export default () => (
  <Router>
    <AppInner>
      <Switch>
        <Route exact path="/login" component={Login} />
        <Route exact path="/sign-up" component={SignUp} />
        <Route exact path="/sign-up/:step" component={SignUp} />
        <ProtectedRoute
          path="/"
          component={() => (
            <>
              <Nav />
              <Switch>
                <Route exact path="/" component={CommunitiesFeatured} />
                <Route exact path="/search" component={Search} />
                <Route
                  exact
                  path="/communities"
                  component={CommunitiesFeatured}
                />
                <Route
                  exact
                  path="/communities/featured"
                  component={CommunitiesFeatured}
                />
                <Route path="/communities/yours" component={CommunitiesYours} />
                <Route
                  exact
                  path="/communities/:community"
                  component={CommunitiesCommunity}
                />
                <Route
                  exact
                  path="/collections"
                  component={() => <div>collections</div>}
                />
                <Route
                  exact
                  path="/collections/featured"
                  component={() => <div>collections featured</div>}
                />
                <Route
                  exact
                  path="/collections/yours"
                  component={() => <div>collections yours</div>}
                />
                <Route
                  exact
                  path="/collections/following"
                  component={() => <div>collections following</div>}
                />
                {/*<Route*/}
                {/*exact*/}
                {/*path="/communities/:community/collections/:collection"*/}
                {/*component={CollectionsCollection}*/}
                {/*/>*/}
                <Route
                  exact
                  path="/communities/:community/collections/:collection/resources/:resource"
                  component={ResourcesResource}
                />
              </Switch>
              <Menu />
            </>
          )}
        />
        <Route component={NotFound} />
      </Switch>
    </AppInner>
  </Router>
);
