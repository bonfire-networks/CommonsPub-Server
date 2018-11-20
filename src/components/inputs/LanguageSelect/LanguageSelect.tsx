import * as React from 'react';
import {
  SelectField as ZenSelectField,
  Select,
  Item
} from '@zendeskgarden/react-select';

import styled, { StyledThemeInterface } from '../../../themes/styled';
import Flag from '../../elements/Flag/Flag';
import { LocaleContext } from '../../../containers/App/App';

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
  en_GB: 'English, United Kingdom',
  en_US: 'English, United States',
  fr: 'French'
};

const options = [
  <Item key="en_GB">
    <Flag flag="gb" />
    &nbsp; {languageNames['en_GB']}
  </Item>,
  <Item key="en_US">
    <Flag flag="us" />
    &nbsp; {languageNames['en_US']}
  </Item>,
  <Item key="fr">
    <Flag flag="fr" />
    &nbsp; {languageNames['fr']}
  </Item>
];

/**
 * TODO this is a dummy implementation of localisation toggling
 */
export default class extends React.Component<
  LanguageSelectProps,
  LanguageSelectState
> {
  state = {
    selectedKey: 'en_GB'
  };

  constructor(props) {
    super(props);
  }

  render() {
    let flagClass = this.state.selectedKey;

    if (this.state.selectedKey.includes('_')) {
      flagClass = this.state.selectedKey.split('_')[1].toLowerCase();
    }

    return (
      <LocaleContext.Consumer>
        {({ setLocale }) => (
          <SelectField {...this.props}>
            <Select
              selectedKey={this.state.selectedKey}
              onChange={selectedKey => {
                setLocale(selectedKey);
                this.setState({ selectedKey });
              }}
              options={options}
            >
              <Flag flag={flagClass} />
              &nbsp;&nbsp;
              {this.props.fullWidth
                ? languageNames[this.state.selectedKey]
                : this.state.selectedKey}
            </Select>
          </SelectField>
        )}
      </LocaleContext.Consumer>
    );
  }
}
