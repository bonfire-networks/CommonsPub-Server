export const vars = {
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
    base5: '#c9c9c9',
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
    h1: '60px',
    h2: '48px',
    h3: '40px',
    h4: '30px',
    h5: '24px',
    h6: '18px',
    p: '16px'
  }
};

export const theme = {
  ...vars,
  // zendesk garden
  'chrome.chrome': {
    fontFamily: vars.fontFamily
  },
  'typography.xxxl': {
    fontFamily: vars.fontFamily,
    fontSize: vars.fontSize.h1
  },
  'typography.xxl': {
    fontFamily: vars.fontFamily,
    fontSize: vars.fontSize.h2
  },
  'typography.xl': {
    fontFamily: vars.fontFamily,
    fontSize: vars.fontSize.h3
  },
  'typography.lg': {
    fontFamily: vars.fontFamily,
    fontSize: vars.fontSize.h4
  },
  'typography.md': {
    fontFamily: vars.fontFamily,
    fontSize: vars.fontSize.h5
  },
  'typography.sm': {
    fontFamily: vars.fontFamily,
    fontSize: vars.fontSize.h6
  },
  'buttons.button': `
        && {
            font-family: ${vars.fontFamily};
            background-color: ${vars.colour.primary};
            color: ${vars.colour.base6};
            border: 2px solid ${vars.colour.primary};
            
            :hover {
                background-color: ${vars.colour.base6};
                border-color: ${vars.colour.primary};
                color: ${vars.colour.primary};
            }
            
            :disabled {
                opacity: 0.5;
                cursor: default;
            }
        }
    `
};
