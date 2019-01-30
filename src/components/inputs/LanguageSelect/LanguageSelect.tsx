import * as React from 'react';
import {
  SelectField as ZenSelectField,
  Select,
  Item
} from '@zendeskgarden/react-select';

import styled, { StyledThemeInterface } from '../../../themes/styled';
import Flag from '../../elements/Flag/Flag';
import { LocaleContext, locale_default } from '../../../containers/App/App';

type LanguageSelectState = {
  selectedKey?: string;
};

type LanguageSelectProps = {
  fullWidth?: boolean;
} & React.SelectHTMLAttributes<object>;

type StyledProps = StyledThemeInterface & LanguageSelectProps;

const SelectField = styled(ZenSelectField)`
  max-width: ${(props: StyledProps) => (props.fullWidth ? 'none' : '300px')};
  width: ${(props: StyledProps) => (props.fullWidth ? '100%' : 'auto')};
`;

export const languageNames = {
  en_GB: 'English, British',
  en_US: 'English, USA',
  es_MX: 'Español, Méjico',
  es_ES: 'Español, España',
  fr_FR: 'Français, France',
  eu: 'Euskara'
};

let options: Item[] = [];

Object.keys(languageNames).forEach(key => {
  // console.log(languageNames[key]);
  options.push(
    <Item key={key}>
      <Flag flag={key.substr(-2).toLowerCase()} />
      &nbsp; {languageNames[key]}
    </Item>
  );
});

// const options = [
//   <Item key="en_GB">
//     <Flag flag="gb" />
//     &nbsp; {languageNames['en_GB']}
//   </Item>,
//   <Item key="en_US">
//     <Flag flag="us" />
//     &nbsp; {languageNames['en_US']}
//   </Item>,
//   <Item key="fr">
//     <Flag flag="fr" />
//     &nbsp; {languageNames['fr']}
//   </Item>
// ];

/**
 * LanguageSelect component.
 * Allows the user to select the active locale being used in the application.
 */
export default class LanguageSelect extends React.Component<
  LanguageSelectProps,
  LanguageSelectState
> {
  state = {
    selectedKey: locale_default
  };

  constructor(props) {
    super(props);
  }

  render() {
    return (
      <LocaleContext.Consumer>
        {({ setLocale, locale }) => (
          <SelectField {...this.props}>
            <Select
              selectedKey={locale}
              onChange={selectedKey => {
                setLocale(selectedKey);
                this.setState({ selectedKey });
              }}
              options={options}
            >
              <Flag flag={locale.substr(-2).toLowerCase()} />
              &nbsp;&nbsp;
              {languageNames[locale]}
            </Select>
          </SelectField>
        )}
      </LocaleContext.Consumer>
    );
  }
}
