import * as React from 'react';
import {
  SelectField as ZenSelectField,
  Select,
  Item
} from '@zendeskgarden/react-select';

import styled, { StyledThemeInterface } from '../../../themes/styled';
import Flag from '../../elements/Flag/Flag';

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
  'en-gb': 'English, United Kingdom',
  'en-us': 'English, United States'
};

const options = [
  <Item key="en-gb">
    <Flag flag="gb" />
    &nbsp; {languageNames['en-gb']}
  </Item>,
  <Item key="en-us">
    <Flag flag="us" />
    &nbsp; {languageNames['en-us']}
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
    selectedKey: 'en-gb'
  };

  constructor(props) {
    super(props);
  }

  render() {
    return (
      <SelectField {...this.props}>
        <Select
          selectedKey={this.state.selectedKey}
          onChange={selectedKey => this.setState({ selectedKey })}
          options={options}
        >
          <Flag flag={this.state.selectedKey.split('-')[1]} />
          &nbsp;&nbsp;
          {this.props.fullWidth
            ? languageNames[this.state.selectedKey]
            : this.state.selectedKey}
        </Select>
      </SelectField>
    );
  }
}
