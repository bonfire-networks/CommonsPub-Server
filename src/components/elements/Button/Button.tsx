import * as React from 'react';
import { Button as ZenButton } from '@zendeskgarden/react-buttons';

import Loader from '../Loader/Loader';

interface ButtonProps extends React.ButtonHTMLAttributes<object> {
  secondary?: boolean;
  // non-HTML attrs. copied from:
  // https://garden.zendesk.com/react-components/buttons/#button
  active?: boolean;
  basic?: boolean;
  buttonRef?: Function;
  danger?: boolean;
  focused?: boolean;
  hovered?: boolean;
  link?: boolean;
  muted?: boolean;
  pill?: boolean;
  primary?: boolean;
  selected?: boolean;
  size?: 'small' | 'large';
  stretched?: boolean;
}

export const LoaderButton = ({ text, loading, type = 'submit', ...props }) => (
  <Button disabled={loading} type={type} {...props}>
    {loading ? <Loader /> : text}
  </Button>
);

/**
 * Button component.
 * @param children {JSX.Element} children of button
 * @param secondary {Boolean} whether button should be styled as secondary button
 * @param className {String} additional class names of the button
 * @param props {Object} button props
 * @constructor
 */
export default function Button({
  children,
  secondary = false,
  className = '',
  ...props
}: ButtonProps) {
  if (secondary) {
    className += ' secondary';
  }
  return (
    <ZenButton className={className} {...props}>
      {children}
    </ZenButton>
  );
}
