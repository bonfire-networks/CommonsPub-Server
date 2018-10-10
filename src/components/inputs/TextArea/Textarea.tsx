import * as React from 'react';
const { Textarea: ZenTextarea } = require('@zendeskgarden/react-textfields');

export default function Textarea({ ...props }) {
  return <ZenTextarea {...props} />;
}
