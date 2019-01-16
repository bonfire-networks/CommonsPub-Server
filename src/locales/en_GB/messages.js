/* eslint-disable */ module.exports = {
  languageData: {
    plurals: function(n, ord) {
      var s = String(n).split('.'),
        v0 = !s[1],
        t0 = Number(s[0]) == n,
        n10 = t0 && s[0].slice(-1),
        n100 = t0 && s[0].slice(-2);
      if (ord)
        return n10 == 1 && n100 != 11
          ? 'one'
          : n10 == 2 && n100 != 12
            ? 'two'
            : n10 == 3 && n100 != 13
              ? 'few'
              : 'other';
      return n == 1 && v0 ? 'one' : 'other';
    }
  },
  messages: {
    'A name or title for the resource': 'A name or title for the resource',
    Account: 'Account',
    'Add a new resource': 'Add a new resource',
    'Add interest': 'Add interest',
    'Add language': 'Add language',
    'Add the first resource': 'Add the first resource',
    'All Collections': 'All Collections',
    'All Communities': 'All Communities',
    Bio: 'Bio',
    Cancel: 'Cancel',
    'Choose a name for the collection': 'Choose a name for the collection',
    'Choose a name for the community': 'Choose a name for the community',
    'Choose a password': 'Choose a password',
    'Choose your password': 'Choose your password',
    'Click to select a profile background image':
      'Click to select a profile background image',
    'Click to select a profile picture': 'Click to select a profile picture',
    Collection: 'Collection',
    Collections: 'Collections',
    Communities: 'Communities',
    Community: 'Community',
    'Confirm password': 'Confirm password',
    'Confirm your password': 'Confirm your password',
    'Could not load the collection.': 'Could not load the collection.',
    'Could not log in. Please check your credentials or use the link below to reset your password.':
      'Could not log in. Please check your credentials or use the link below to reset your password.',
    'Could not search at this time, please try again later.':
      'Could not search at this time, please try again later.',
    Create: 'Create',
    'Create a community': 'Create a community',
    'Create a new account': 'Create a new account',
    'Create a new collection': 'Create a new collection',
    'Create a new community': 'Create a new community',
    'Create the first collection': 'Create the first collection',
    Description: 'Description',
    Discussions: 'Discussions',
    'Display Name': 'Display Name',
    Edit: 'Edit',
    'Edit profile': 'Edit profile',
    'Edit the collection details': 'Edit the collection details',
    'Edit the community details': 'Edit the community details',
    'Edit the resource details': 'Edit the resource details',
    Email: 'Email',
    'Email address': 'Email address',
    'Emoji ID': 'Emoji ID',
    'Enter the URL of an image to represent the collection':
      'Enter the URL of an image to represent the collection',
    'Enter the URL of an image to represent the community':
      'Enter the URL of an image to represent the community',
    'Enter the URL of an image to represent the resource':
      'Enter the URL of an image to represent the resource',
    'Enter the URL of the resource': 'Enter the URL of the resource',
    'Enter your email': 'Enter your email',
    'Enter your password': 'Enter your password',
    'Error loading collections': 'Error loading collections',
    'Error loading communities': 'Error loading communities',
    'Favourite Collections': 'Favourite Collections',
    'Featured Collections': 'Featured Collections',
    'Here are some trending tags you could add':
      'Here are some trending tags you could add',
    Image: 'Image',
    Interests: 'Interests',
    'Introduce yourself to the community...':
      'Introduce yourself to the community...',
    Language: 'Language',
    Languages: 'Languages',
    Link: 'Link',
    Location: 'Location',
    Members: 'Members',
    'My Collections': 'My Collections',
    Name: 'Name',
    'No {something} selected': function(a) {
      return ['No ', a('something'), ' selected'];
    },
    'Page not found': 'Page not found',
    Password: 'Password',
    'Please describe what the collection is for and what kind of resources it is likely to contain...':
      'Please describe what the collection is for and what kind of resources it is likely to contain...',
    'Please describe who might be interested in this community and what kind of collections it is likely to contain...':
      'Please describe who might be interested in this community and what kind of collections it is likely to contain...',
    'Please type or copy/paste a summary about the resource...':
      'Please type or copy/paste a summary about the resource...',
    'Popular on MoodleNet': 'Popular on MoodleNet',
    'Popular search phrases': 'Popular search phrases',
    'Popular tags': 'Popular tags',
    Profile: 'Profile',
    Resources: 'Resources',
    Save: 'Save',
    Search: 'Search',
    'Search Results': 'Search Results',
    'Search for tags': 'Search for tags',
    'Search results for {query}': function(a) {
      return ['Search results for ', a('query')];
    },
    'Searching...': 'Searching...',
    Settings: 'Settings',
    Shuffle: 'Shuffle',
    'Sign Up': 'Sign Up',
    'Sign in': 'Sign in',
    'Sign out': 'Sign out',
    'Sorry, we encountered a problem loading the app in your language.':
      'Sorry, we encountered a problem loading the app in your language.',
    'The email field cannot be empty': 'The email field cannot be empty',
    'The password field cannot be empty': 'The password field cannot be empty',
    'This data will never be shared.': 'This data will never be shared.',
    'This information will appear on your public profile.':
      'This information will appear on your public profile.',
    'Your Communities': 'Your Communities',
    'Your Interests': 'Your Interests',
    'Your interests will be displayed on your profile, and will also help MoodleNet recommend content that is relevant to you.':
      'Your interests will be displayed on your profile, and will also help MoodleNet recommend content that is relevant to you.',
    'e.g. Moodler Mary': 'e.g. Moodler Mary',
    'e.g. United Kingdom': 'e.g. United Kingdom',
    'e.g. mary@moodlers.org': 'e.g. mary@moodlers.org',
    'e.g. russian revolution 1917': 'e.g. russian revolution 1917',
    'eg. Moodler Mary': 'eg. Moodler Mary',
    'eg. mary@moodlers.org': 'eg. mary@moodlers.org'
  }
};
