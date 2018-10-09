import * as React from 'react';

const { Button: ZenButton } = require('@zendeskgarden/react-buttons');

export default function Button({ children }) {
  return <ZenButton>{children}</ZenButton>;
}
