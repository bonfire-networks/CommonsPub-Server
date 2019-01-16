/* eslint-disable */ module.exports = {
  languageData: {
    plurals: function(n, ord) {
      if (ord) return 'other';
      return n == 1 ? 'one' : 'other';
    }
  },
  messages: {
    Account: 'Account',
    'Add a new resource': 'Add a new resource',
    'Add interest': 'Add interest',
    'Add language': 'Add language',
    'Add the first resource': 'Add the first resource',
    'All Collections': 'All Collections',
    'All Communities': 'All Communities',
    Bio: 'Bio',
    'Browse as a guest': 'Browse as a guest',
    'Click to select a profile background':
      'Click to select a profile background',
    'Click to select a profile background image':
      'Click to select a profile background image',
    'Click to select a profile picture': 'Click to select a profile picture',
    Collections: 'Collections',
    Communities: 'Communities',
    'Could not load the collection.': 'Could not load the collection.',
    'Could not log in. Please check your credentials or use the link below to reset your password.':
      'Could not log in. Please check your credentials or use the link below to reset your password.',
    'Could not search at this time, please try again later.':
      'Could not search at this time, please try again later.',
    'Create a new collection': 'Create a new collection',
    'Create an account': 'Create an account',
    'Create the first collection': 'Create the first collection',
    Discussions: 'Discussions',
    Edit: 'Edit',
    'Email address': 'Email address',
    'Emoji ID': 'Emoji ID',
    'Enter your email': 'Enter your email',
    'Enter your password': 'Enter your password',
    'Error loading collections': 'Error loading collections',
    'Error loading communities': 'Error loading communities',
    'First time?': 'First time?',
    'Forgotten your password?': 'Forgotten your password?',
    'Here are some trending tags you could add':
      'Here are some trending tags you could add',
    Interests: 'Interests',
    Language: 'Language',
    Languages: 'Languages',
    Location: 'Location',
    Name: 'Name',
    'No {something} selected': function(a) {
      return ['No ', a('something'), ' selected'];
    },
    'Page not found': 'Page not found',
    Password: 'Password',
    'Popular on MoodleNet': 'Popular on MoodleNet',
    Profile: 'Profile',
    Resources: 'Resources',
    Search: 'Search',
    'Search Results': 'Search Results',
    'Search results for {query}': function(a) {
      return ['Search results for ', a('query')];
    },
    'Searching...': 'Searching...',
    Shuffle: 'Shuffle',
    'Sign in': 'Sign in',
    'Sign in using your social media account':
      'Sign in using your social media account',
    'The email field cannot be empty': 'The email field cannot be empty',
    'The password field cannot be empty': 'The password field cannot be empty',
    'These are some trending tags': 'These are some trending tags',
    'This data will never be shared.': 'This data will never be shared.',
    'This information will appear on your public profile.':
      'This information will appear on your public profile.',
    "You don't need an account to browse {site_name}.": function(a) {
      return ["You don't need an account to browse ", a('site_name'), '.'];
    },
    'You need to sign up to participate in discussions. You can use a social media account to sign in, or create an account manually.':
      'You need to sign up to participate in discussions. You can use a social media account to sign in, or create an account manually.',
    'Your Communities': 'Your Communities',
    'Your Interests': 'Your Interests',
    'Your interests will be displayed on your profile, and will also help MoodleNet recommend content that is relevant to you.':
      'Your interests will be displayed on your profile, and will also help MoodleNet recommend content that is relevant to you.'
  }
};
