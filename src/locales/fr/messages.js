/* eslint-disable */ module.exports = {
  languageData: {
    plurals: function(n, ord) {
      if (ord) return n == 1 ? 'one' : 'other';
      return n >= 0 && n < 2 ? 'one' : 'other';
    }
  },
  messages: {
    'Browse as a guest': 'french',
    'Could not log in. Please check your credentials or use the link below to reset your password.':
      'Could not log in. Please check your credentials or use the link below to reset your password.',
    'Create an account': 'Create an account',
    'Email address': 'Email address',
    'Enter your email': 'Enter your email',
    'Enter your password': 'Enter your password',
    'First time?': 'First time?',
    'Forgotten your password?': 'Forgotten your password?',
    Password: 'Password',
    'Sign in': 'Sign in',
    'Sign in using your social media account':
      'Sign in using your social media account',
    'The email field cannot be empty': 'The email field cannot be empty',
    'The password field cannot be empty': 'The password field cannot be empty',
    "You don't need an account to browse {site_name}.": function(a) {
      return ["You don't need an account to browse ", a('site_name'), '.'];
    },
    'You need to sign up to participate in discussions. You can use a social media account to sign in, or create an account manually.':
      'You need to sign up to participate in discussions. You can use a social media account to sign in, or create an account manually.'
  }
};
