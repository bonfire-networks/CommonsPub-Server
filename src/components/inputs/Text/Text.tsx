import * as React from 'react';
const { Input } = require('@zendeskgarden/react-textfields');

export default function Text({ ...props }) {
  return <Input {...props} />;
}
