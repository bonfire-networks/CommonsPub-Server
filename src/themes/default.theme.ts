import createTheme from './create';

const themeLight = createTheme({
  colour: {
    background: '#f5f6f7',
    header: '#f98012',
    headerLink: '#fff',
    breadcrumb: '#fff',

    communityBg: '#eaeef0',
    communityTitle: '#282828',
    communityNote: '#3c3c3c',
    communityIcon: '#848383',

    collectionBg: '#eaeef0',
    collectionTitle: '#282828',
    collectionNote: '#3c3c3c',
    collectionIcon: '#848383',

    primary: '#f98012',
    secondary: '#686566',
    logo: '#fff',
    primaryAlt: '#FF9D00',
    primaryDark: '#686566',
    // base colours
    base1: '#282828',
    base2: '#3c3c3c',
    base3: '#848383',
    base4: '#c9c9c9',
    base5: '#f7f7f7',
    base6: '#3c3c3c',
    blue1: '#7ac2d6',
    blue2: '#239cae',
    blue3: '#005a75',
    green1: '#9cbd50',
    green2: '#2ca14f',
    green3: '#316d5e'
  },
  fontFamily: '"Open Sans", sans-serif',
  fontWeight: {
    light: 300,
    regular: 400,
    semibold: 600,
    bold: 700
  },
  fontSize: {
    // headings
    xxxl: '60px',
    xxl: '48px',
    xl: '40px',
    lg: '30px',
    md: '24px',
    sm: '18px',
    // paragraph
    xs: '16px'
  },
  lineHeight: {
    xxxl: '72px',
    xxl: '61px',
    xl: '58px',
    lg: '44px',
    md: '38px',
    sm: '29px',
    xs: '18px'
  }
});

const themeDark = createTheme({
  colour: {
    background: '#282a36',
    header: '#46495a',
    headerLink: '#fff',
    breadcrumb: '#46495a',

    communityBg: '#eaeef0',
    communityTitle: '#282828',
    communityNote: '#3c3c3c',
    communityIcon: '#848383',

    collectionBg: '#eaeef0',
    collectionTitle: '#282828',
    collectionNote: '#3c3c3c',
    collectionIcon: '#848383',

    primary: '#f8f8f2',
    secondary: '#686566',
    logo: '#fff',
    primaryAlt: 'black',
    primaryDark: 'black',
    // base colours
    base1: '#f7f7f7',
    base2: '#3c3c3c',
    base3: '#848383',
    base4: '#c9c9c9',
    base5: '#f7f7f7',
    base6: '#dddee4',
    blue1: '#7ac2d6',
    blue2: '#239cae',
    blue3: '#005a75',
    green1: '#9cbd50',
    green2: '#2ca14f',
    green3: '#316d5e'
  },
  fontFamily: '"Open Sans", sans-serif',
  fontWeight: {
    light: 300,
    regular: 400,
    semibold: 600,
    bold: 700
  },
  fontSize: {
    // headings
    xxxl: '60px',
    xxl: '48px',
    xl: '40px',
    lg: '30px',
    md: '24px',
    sm: '18px',
    // paragraph
    xs: '16px'
  },
  lineHeight: {
    xxxl: '72px',
    xxl: '61px',
    xl: '58px',
    lg: '44px',
    md: '38px',
    sm: '29px',
    xs: '18px'
  }
});

export const theme = mode => (mode === 'dark' ? themeDark : themeLight);
