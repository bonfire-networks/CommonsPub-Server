import * as React from 'react';
import { Button as ZenButton } from '@zendeskgarden/react-buttons';

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

const Button: React.SFC<ButtonProps> = ({
  children,
  secondary = false,
  className = '',
  ...props
}) => {
  if (secondary) {
    className += ' secondary';
  }
  return (
    <ZenButton className={className} {...props}>
      {children}
    </ZenButton>
  );
};

// TODO why is this @ts-ignore directive necessary?
// @ts-ignore
export default Button;
