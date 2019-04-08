import React from 'react';
import { moodlenet } from '../themes';
import { ThemeProvider as ZenThemeProvider } from '@zendeskgarden/react-theming';

const defaultContextData = {
  dark: false,
  toggle: () => {}
};

const ThemeContext = React.createContext(defaultContextData);
const useTheme = () => React.useContext(ThemeContext);

const useEffectDarkMode = () => {
  const [themeState, setThemeState] = React.useState<any>({
    dark: false,
    hasThemeMounted: false
  });

  React.useEffect(() => {
    const lsDark = localStorage.getItem('dark') === 'true';
    setThemeState({ ...themeState, dark: lsDark, hasThemeMounted: true });
  }, []);

  return [themeState, setThemeState];
};

const ThemeProvider = ({ children }) => {
  const [themeState, setThemeState] = useEffectDarkMode();
  if (!themeState.hasThemeMounted) {
    return <div />;
  }

  const toggle = () => {
    const dark = !themeState.dark;
    localStorage.setItem('dark', JSON.stringify(dark));
    setThemeState({ ...themeState, dark });
  };
  const computedTheme = themeState.dark
    ? moodlenet('dark')
    : moodlenet('light');
  return (
    <ZenThemeProvider theme={computedTheme}>
      <ThemeContext.Provider
        value={{
          dark: themeState!.dark,
          toggle
        }}
      >
        {children}
      </ThemeContext.Provider>
    </ZenThemeProvider>
  );
};

export { ThemeProvider, useTheme };
