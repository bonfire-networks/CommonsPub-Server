import * as styledComponents from 'styled-components';
import { ThemedStyledComponentsModule } from 'styled-components';

export interface MoodleThemeInterface {
  colour: {
    primary: string;
    primaryAlt: string;
    primaryDark: string;
    community: string;
    collection: string;
    base1: string;
    base2: string;
    base3: string;
    base4: string;
    base5: string;
    base6: string;
  };
  fontFamily: string;
  fontWeight: {
    light: number;
    regular: number;
    semibold: number;
    bold: number;
  };
  fontSize: {
    xxxl: string;
    xxl: string;
    xl: string;
    lg: string;
    md: string;
    sm: string;
    xs: string;
  };
  lineHeight: {
    xxxl: string;
    xxl: string;
    xl: string;
    lg: string;
    md: string;
    sm: string;
    xs: string;
  };
}

// MoodleNet theme interface, defines the shape of a theme definition
export interface ThemeInterface {
  // There is a "styles" parent property on the interface because
  // we are using Zendesk Garden which provides its own ThemeProvider,
  // which places the consumer theme at `props.theme.styles` instead
  // of the styled-components' usual `props.theme`.
  // https://garden.zendesk.com/react-components/theming/#themeprovider
  styles: MoodleThemeInterface;
}

export interface StyledThemeInterface {
  theme: ThemeInterface;
}

const {
  default: styled,
  css,
  injectGlobal,
  keyframes,
  ThemeProvider,
  withTheme
} = styledComponents as ThemedStyledComponentsModule<ThemeInterface>;

export { css, injectGlobal, keyframes, ThemeProvider, withTheme };

export default styled;
