```js
const redGroupCommunityBg = require('../../../static/img/styleguide/the-red-group-community.png');
const russianRevolutionBg = require('../../../static/img/styleguide/russian-revolution-collection.png');
const runawayRussiaBg = require('../../../static/img/styleguide/runaway-russia-resource.png');
const { CollectionCard, CommunityCard, ResourceCard } = require('./Card.tsx');
const { BrowserRouter } = require('react-router-dom');

<BrowserRouter>
  <div style={{ display: 'flex', flexDirection: 'row' }}>
    <div>
      Community
      <CommunityCard
        title="The Red Group"
        contentCounts={{ Members: 6, Collections: 5 }}
        onButtonClick={() => alert('card clicked')}
        joined={true}
        backgroundImage={redGroupCommunityBg}
      />
    </div>
    <div>
      Collection
      <CollectionCard
        title="Russian In Revolution"
        contentCounts={{ Followers: 14, Resources: 5 }}
        onButtonClick={() => alert('card clicked')}
        joined={false}
        backgroundImage={russianRevolutionBg}
      />
    </div>
    <div>
      Resource
      <ResourceCard
        title="Runaway Russia: An American Woman Reports on the Russian Revolution"
        likesCount={4}
        source="#"
        backgroundImage={runawayRussiaBg}
      />
    </div>
  </div>
</BrowserRouter>;
```
