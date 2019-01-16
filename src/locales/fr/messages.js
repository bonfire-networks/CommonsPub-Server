/* eslint-disable */ module.exports = {
  languageData: {
    plurals: function(n, ord) {
      if (ord) return n == 1 ? 'one' : 'other';
      return n >= 0 && n < 2 ? 'one' : 'other';
    }
  },
  messages: {
    'A name or title for the resource': 'Un nom ou un titre pour la ressource',
    Account: 'Compte',
    'Add a new resource': 'Ajouter une nouvelle ressource',
    'Add interest': 'Ajouter un int\xE9r\xEAt',
    'Add language': 'Ajouter une langue',
    'Add the first resource': 'Ajouter la premi\xE8re ressource',
    'All Collections': 'Toutes les collections',
    'All Communities': 'Toutes les communaut\xE9s',
    Bio: 'Biographie',
    Cancel: 'Annuler',
    'Choose a name for the collection': 'Choisissez un nom pour la collection',
    'Choose a name for the community':
      'Choisissez un nom pour la communaut\xE9',
    'Choose a password': 'Choisissez un mot de passe',
    'Click to select a profile background image':
      'Cliquez pour s\xE9lectionner une image de fond pour votre profil',
    'Click to select a profile picture':
      'Cliquez pour s\xE9lectionner une photo de profil',
    Collection: 'Collection',
    Collections: 'Collections',
    Communities: 'Communaut\xE9s',
    Community: 'Communaut\xE9',
    'Could not load the collection.': "Impossible d'afficher la collection.",
    'Could not log in. Please check your credentials or use the link below to reset your password.':
      'Impossible de se connecter. Veuillez v\xE9rifier vos informations ou utilisez le lien ci-dessous pour r\xE9initialiser votre mot de passe.',
    'Could not search at this time, please try again later.':
      "Impossible d'effectuer une recherche pour le moment, veuillez r\xE9essayer ult\xE9rieurement.",
    Create: 'Cr\xE9er',
    'Create a community': 'Cr\xE9er une communaut\xE9',
    'Create a new collection': 'Cr\xE9er une nouvelle collection',
    'Create a new community': 'Cr\xE9er une nouvelle communaut\xE9',
    'Create the first collection': 'Cr\xE9er la premi\xE8re collection',
    Description: 'Description',
    Discussions: 'Discussions',
    Edit: 'Modifier',
    'Edit profile': 'Modifier mon profil',
    'Edit the collection details': 'Modifier les d\xE9tails de la collection',
    'Edit the community details': 'Modifier les d\xE9tails de la communaut\xE9',
    'Edit the resource details': 'Modifier les d\xE9tails de la ressource',
    'Email address': 'Adresse \xE9lectronique',
    'Emoji ID': 'Emoji ID',
    'Enter the URL of an image to represent the collection':
      "Entrez l'URL d'une image pour repr\xE9senter la collection",
    'Enter the URL of an image to represent the community':
      "Entrez l'URL d'une image pour repr\xE9senter la communaut\xE9",
    'Enter the URL of an image to represent the resource':
      "Entrez l'URL d'une image pour repr\xE9senter la ressource",
    'Enter the URL of the resource': "Entrez l'URL de la ressource",
    'Enter your email': 'Entrez votre e-mail',
    'Enter your password': 'Entrez votre mot de passe',
    'Error loading collections': 'Erreur lors du chargement des collections',
    'Error loading communities': 'Erreur lors du chargement des communaut\xE9s',
    'Favourite Collections': 'Collections pr\xE9f\xE9r\xE9es',
    'Featured Collections': 'Collections interessantes',
    'Here are some trending tags you could add':
      'Voici quelques balises tendance que vous pourriez ajouter',
    Image: 'Image',
    Interests: 'Int\xE9r\xEAts',
    'Introduce yourself to the community...':
      'Pr\xE9sentez vous \xE0 la communaut\xE9...',
    Language: 'Langue',
    Languages: 'Langues',
    Link: 'Lien',
    Location: 'Ville / Pays',
    Members: 'Membres',
    'My Collections': 'Mes collections',
    Name: 'Nom',
    'No {something} selected': function(a) {
      return ['Aucun(e) ', a('something'), ' s\xE9lectionn\xE9(e)'];
    },
    'Page not found': 'Page non trouv\xE9e',
    Password: 'Mot de passe',
    'Please describe what the collection is for and what kind of resources it is likely to contain...':
      'Veuillez d\xE9crire \xE0 quoi peut servir la collection et quel type(s) de ressources elle est susceptible de contenir...',
    'Please describe who might be interested in this community and what kind of collections it is likely to contain...':
      'Veuillez d\xE9crire qui pourrait \xEAtre int\xE9ress\xE9 par cette communaut\xE9 et quel type(s) de collections elle est susceptible de contenir...',
    'Please type or copy/paste a summary about the resource...':
      'Veuillez taper ou copier/coller une description de cette ressource...',
    'Popular on MoodleNet': 'Populaire sur MoodleNet',
    'Popular search phrases': 'Phrases de recherche populaires',
    'Popular tags': 'Tags populaires',
    Profile: 'Profil',
    Resources: 'Ressources',
    Save: 'Sauvegarder',
    Search: 'Rechercher',
    'Search Results': 'R\xE9sultats de la recherche',
    'Search for tags': 'Rechercher des tags',
    'Search results for {query}': function(a) {
      return ['R\xE9sultats de recherche pour ', a('query')];
    },
    'Searching...': 'Recherche en cours...',
    Settings: 'Options',
    Shuffle: 'Autre',
    'Sign in': 'Se connecter',
    'Sign out': 'D\xE9connexion',
    'Sorry, we encountered a problem loading the app in your language.':
      "D\xE9sol\xE9, nous avons rencontr\xE9 un probl\xE8me lors du chargement de l'application dans votre langue.",
    'The email field cannot be empty': "L'email ne peut pas \xEAtre vide",
    'The password field cannot be empty':
      'Le mot de passe ne peut pas \xEAtre vide',
    'This data will never be shared.':
      'Ces donn\xE9es ne seront jamais partag\xE9es.',
    'This information will appear on your public profile.':
      'Ces informations appara\xEEtront sur votre profil public.',
    'Your Communities': 'Vos communaut\xE9s',
    'Your Interests': 'Vos int\xE9r\xEAts',
    'Your interests will be displayed on your profile, and will also help MoodleNet recommend content that is relevant to you.':
      'Vos centres d\u2019int\xE9r\xEAt seront affich\xE9s sur votre profil et aideront \xE9galement MoodleNet \xE0 vous recommander du contenu pertinent.',
    'e.g. Moodler Mary': 'ex. : Marie Moodler',
    'e.g. United Kingdom': 'ex. : France',
    'e.g. mary@moodlers.org': 'ex. : marie@moodlers.org',
    'e.g. russian revolution 1917': 'ex. : r\xE9volution russe 1917'
  }
};
