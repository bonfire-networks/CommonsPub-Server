import * as React from 'react';
import {
  SelectField as ZenSelectField,
  Select,
  Item
} from '@zendeskgarden/react-select';

import styled from '../../../themes/styled';
import Flag from '../../elements/Flag/Flag';

type LanguageSelectState = {
  selectedKey?: string;
};

const SelectField = styled(ZenSelectField)`
  max-width: 300px;
`;

const options = [
  <Item key="en-gb">
    <Flag flag="gb" />
    &nbsp; English, United Kingdom
  </Item>,
  <Item key="en-us">
    <Flag flag="us" />
    &nbsp; English, United States
  </Item>
];

/**
 * TODO this is a dummy implementation of localisation toggling
 */
export default class extends React.Component<{}, LanguageSelectState> {
  state = {
    selectedKey: 'en-gb'
  };

  constructor(props) {
    super(props);
  }

  render() {
    return (
      <SelectField>
        <Select
          selectedKey={this.state.selectedKey}
          onChange={selectedKey => this.setState({ selectedKey })}
          options={options}
        >
          <Flag flag={this.state.selectedKey.split('-')[1]} />
          &nbsp;&nbsp;
          {this.state.selectedKey}
        </Select>
      </SelectField>
    );
  }
}
