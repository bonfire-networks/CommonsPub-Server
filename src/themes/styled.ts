import * as styledComponents from 'styled-components';
import { ThemedStyledComponentsModule } from 'styled-components';

export interface ThemeInterface {
  // There is a "styles" parent property on the interface because
  // we are using Zendesk Garden which provides its own ThemeProvider,
  // which places the consumer theme at `props.theme.styles` instead
  // of the styled-components' usual `props.theme`.
  // https://garden.zendesk.com/react-components/theming/#themeprovider
  styles: {
    colour: {
      primary: string;
      community: string;
      collection: string;
      base1: string;
      base2: string;
      base3: string;
      base4: string;
      base5: string;
      base6: string;
    };
    fontFamily: {
      light: string;
      regular: string;
      semibold: string;
      bold: string;
    };
    fontSize: {
      h1: string;
      h2: string;
      h3: string;
      h4: string;
      h5: string;
      h6: string;
      p: string;
    };
  };
}

const {
  default: styled,
  css,
  injectGlobal,
  keyframes,
  ThemeProvider
} = styledComponents as ThemedStyledComponentsModule<ThemeInterface>;

export { css, injectGlobal, keyframes, ThemeProvider };

export default styled;
