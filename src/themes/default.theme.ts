import createTheme from './create';

export const theme = createTheme({
  colour: {
    primary: '#f98012',
    // secondary colours
    community: '#3f51b5',
    collection: '#2196f3',
    // base colours
    base1: '#1e1f24',
    base2: '#3c3c3c',
    base3: '#848383',
    base4: '#c9c9c9',
    base5: '#f7f7f7',
    base6: '#ffffff'
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
