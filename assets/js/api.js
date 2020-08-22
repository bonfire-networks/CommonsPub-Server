function graphql(query) {
  // Make a POST request
  fetch("/api/graphql", {
    method: "POST",
    body: query,
    headers: {
      "application/json": "",
    },
  })
    .then(function (response) {
      if (response.ok) {
        return response.json();
      }
      return Promise.reject(response);
    })
    .then(function (data) {
      console.log(data);
      return data;
    })
    .catch(function (error) {
      console.warn("Something went wrong.", error);
    });
}

// graphql(
//   "{ spatialThingsPages {  edges {    id    name    mappableAddress    geom  }}}"
// );
