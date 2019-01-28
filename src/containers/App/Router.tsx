import * as React from 'react';
import Loadable from 'react-loadable';
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom';

import styled from '../../themes/styled';

import { Trans } from '@lingui/macro';

// import Menu from '../../components/chrome/Menu/Menu';
import Nav from '../../components/chrome/Nav/Nav';
import CommunitiesFeatured from '../../pages/communities.featured/CommunitiesFeatured';
import CollectionsFeatured from '../../pages/collections.featured/CollectionsFeatured';
import CommunitiesYours from '../../pages/communities.yours/CommunitiesYours';
import CommunitiesCommunity from '../../pages/communities.community/CommunitiesCommunity';
import CollectionsCollection from '../../pages/collections.collection/CollectionsCollection';
import Header from '../../components/header';
import Login from '../../pages/login/Login';
import NotFound from '../../pages/not-found/NotFound';
import ProtectedRoute from './ProtectedRoute';
import Loader from '../../components/elements/Loader/Loader';
import Search from '../../pages/search/Search';
import Thread from '../../pages/thread';
import Home from '../../pages/home';
const AppInner = styled.div`
  display: flex;
  flex-direction: row;
  width: 100%;
  height: 100%;
`;
const Main = styled.div`
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 100%;
  flex: 1;
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

/**
 * The application routes definition.
 *
 * Note that all routes requiring the user to be authenticated are within
 * the ProtectedRoute component, which then delegates further routing to a
 * Switch route component.
 */
export default () => (
  <Router>
    <AppInner>
      <Switch>
        <Route exact path="/readme" component={Home} />
        <Route exact path="/login" component={Login} />
        <Route exact path="/sign-up" component={SignUp} />
        <Route exact path="/sign-up/:step" component={SignUp} />
        <ProtectedRoute
          path="/"
          component={props => (
            <>
              <Nav />
              <Main>
                <Header history={props.history} />
                <Switch>
                  <Route exact path="/" component={Home} />
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
                  <Route
                    path="/communities/yours"
                    component={CommunitiesYours}
                  />
                  <Route
                    exact
                    path="/communities/:community"
                    component={CommunitiesCommunity}
                  />
                  <Route exact path="/thread/:id" component={Thread} />
                  <Route
                    exact
                    path="/collections"
                    component={CollectionsFeatured}
                  />
                  <Route
                    exact
                    path="/collections/featured"
                    component={() => (
                      <div>
                        <Trans>Featured Collections</Trans>
                      </div>
                    )}
                  />
                  <Route
                    exact
                    path="/collections/yours"
                    component={() => (
                      <div>
                        <Trans>My Collections</Trans>
                      </div>
                    )}
                  />
                  <Route
                    exact
                    path="/collections/following"
                    component={() => (
                      <div>
                        <Trans>Favourite Collections</Trans>
                      </div>
                    )}
                  />
                  <Route
                    exact
                    path="/communities/:community/collections/:collection"
                    component={CollectionsCollection}
                  />
                  {/*<Route*/}
                  {/*exact*/}
                  {/*path="/communities/:community/collections/:collection/resources/:resource"*/}
                  {/*component={ResourcesResource}*/}
                  {/*/>*/}
                  <Route component={NotFound} />
                </Switch>
              </Main>
              {/* <Menu /> */}
            </>
          )}
        />
        <Route component={NotFound} />
      </Switch>
    </AppInner>
  </Router>
);
