```js
// import CollectionCard from './Collection'
const collection = {
  followersCount: 10,
  resourcesCount: 8,
  icon: 'unsplash.it/200',
  id: '1',
  localId: '5',
  preferredUsername: 'Vietnam_war',
  name: 'Vietnam war',
  summary:
    'If you have an API endpoint that alters data, like inserting data into a database or altering data already in a database, you should make this endpoint a Mutation rather than a Query. This is as simple as making the API endpoint part of the top-level Mutation type instead of the top-level Query type.'
};
// <div>
// <button>ciao</button>
<div>
  <Collection key={1} collection={collection} />
</div>;
```
