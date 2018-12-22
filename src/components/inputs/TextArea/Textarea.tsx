import * as React from 'react';
const { Textarea: ZenTextarea } = require('@zendeskgarden/react-textfields');

/**
 * Textarea component.
 * @param props {Object} props of Textarea
 * @constructor
 */
export default function Textarea({ ...props }) {
  return <ZenTextarea {...props} />;
}
