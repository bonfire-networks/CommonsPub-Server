import * as React from 'react';
import { Input } from '@zendeskgarden/react-textfields';

import styled from '../../../themes/styled';
import { InputHTMLAttributes } from 'react';
import { ValidationType } from '../../../pages/login/types';

type TextArgs = {
  button?: JSX.Element;
  //TODO copy over zen garden props and use proper validation types
  validation?: ValidationType | null;
} & InputHTMLAttributes<object>;

const WithButton = styled.div`
  display: flex;
  flex-direction: row;

  & > input {
    border-top-right-radius: 0;
    border-bottom-right-radius: 0;
    border-right: 0;
  }

  & > button {
    border-top-left-radius: 0;
    border-bottom-left-radius: 0;
  }
`;

/**
 * Text component.
 * @param button {JSX.Element} children of text component
 * @param props {Object} props of text component
 * @constructor
 */
export default function Text({ button, ...props }: TextArgs) {
  if (button) {
    return (
      <WithButton>
        <Input {...props} />
        {button}
      </WithButton>
    );
  }

  return <Input {...props} />;
}
