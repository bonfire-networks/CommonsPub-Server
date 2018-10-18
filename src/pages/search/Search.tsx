import * as React from 'react';

export default ({ match }) => {
  //TODO support maybe not good enough? e.g. no ie 11 (https://caniuse.com/#feat=urlsearchparams)
  //TODO this is not SSR friendly, accessing window.location!! does react router give query params?
  const urlParams = new URLSearchParams(window.location.search);
  const query = urlParams.get('q');

  if (!query) {
    return <div>no query</div>;
  }

  return <div>search: {query}</div>;
};
