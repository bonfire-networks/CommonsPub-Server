const communityBg = require('../static/img/styleguide/the-red-group-community.png');
const collectionBg = require('../static/img/styleguide/russian-revolution-collection.png');
const resourceBg = require('../static/img/styleguide/runaway-russia-resource.png');

const rand = () => Math.max(1, Math.floor(Math.random() * 20));

const description =
  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ornare pretium tellus ut laoreet. Donec nec pulvinar diam. Fusce sed est sed sem condimentum porttitor eget non turpis. Sed dictum pulvinar dui, iaculis ultrices orci scelerisque non. Integer a dignissim arcu. Nunc eu mi orci. Fusce ante sapien, elementum in gravida ut, porta ut erat. Suspendisse potenti.';

export const DUMMY_COMMUNITIES = [
  {
    id: 0,
    title: 'The Red Group',
    backgroundImage: communityBg,
    description,
    contentCounts: {
      Members: rand(),
      Collections: rand()
    },
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 1,
    title: 'The Red Group',
    backgroundImage: communityBg,
    description,
    contentCounts: {
      Members: rand(),
      Collections: rand()
    },
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 2,
    title: 'The Red Group',
    backgroundImage: communityBg,
    description,
    contentCounts: {
      Members: rand(),
      Collections: rand()
    },
    onButtonClick: () => alert('card btn clicked')
  }
];

export const DUMMY_COLLECTIONS = [
  {
    id: 0,
    title: 'The Russian Revolution',
    description,
    backgroundImage: collectionBg,
    contentCounts: {
      Followers: rand(),
      Resources: rand()
    },
    community: DUMMY_COMMUNITIES[0],
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 1,
    title: 'The Russian Revolution',
    description,
    backgroundImage: collectionBg,
    contentCounts: {
      Followers: rand(),
      Resources: rand()
    },
    community: DUMMY_COMMUNITIES[0],
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 2,
    title: 'The Russian Revolution',
    description,
    backgroundImage: collectionBg,
    contentCounts: {
      Followers: rand(),
      Resources: rand()
    },
    community: DUMMY_COMMUNITIES[0],
    onButtonClick: () => alert('card btn clicked')
  }
];

export const DUMMY_RESOURCES = [
  {
    id: 0,
    title:
      'Runaway Russia: An American Woman Reports on the Russian Revolution',
    description,
    source: '#',
    likesCount: rand(),
    backgroundImage: resourceBg,
    collection: DUMMY_COLLECTIONS[0],
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 1,
    title:
      'Runaway Russia: An American Woman Reports on the Russian Revolution',
    description,
    source: '#',
    likesCount: rand(),
    backgroundImage: resourceBg,
    collection: DUMMY_COLLECTIONS[0],
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 2,
    title:
      'Runaway Russia: An American Woman Reports on the Russian Revolution',
    description,
    source: '#',
    likesCount: rand(),
    backgroundImage: resourceBg,
    collection: DUMMY_COLLECTIONS[0],
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 3,
    title:
      'Runaway Russia: An American Woman Reports on the Russian Revolution',
    description,
    source: '#',
    likesCount: rand(),
    backgroundImage: resourceBg,
    collection: DUMMY_COLLECTIONS[0],
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 4,
    title:
      'Runaway Russia: An American Woman Reports on the Russian Revolution',
    description,
    source: '#',
    likesCount: rand(),
    backgroundImage: resourceBg,
    collection: DUMMY_COLLECTIONS[0],
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 5,
    title:
      'Runaway Russia: An American Woman Reports on the Russian Revolution',
    description,
    source: '#',
    likesCount: rand(),
    backgroundImage: resourceBg,
    collection: DUMMY_COLLECTIONS[0],
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 6,
    title:
      'Runaway Russia: An American Woman Reports on the Russian Revolution',
    description,
    source: '#',
    likesCount: rand(),
    backgroundImage: resourceBg,
    collection: DUMMY_COLLECTIONS[0],
    onButtonClick: () => alert('card btn clicked')
  },
  {
    id: 7,
    title:
      'Runaway Russia: An American Woman Reports on the Russian Revolution',
    description,
    source: '#',
    likesCount: rand(),
    backgroundImage: resourceBg,
    collection: DUMMY_COLLECTIONS[0],
    onButtonClick: () => alert('card btn clicked')
  }
];
