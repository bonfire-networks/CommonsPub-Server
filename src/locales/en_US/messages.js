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
    'Browse as a guest': 'Browse as a guest',
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
