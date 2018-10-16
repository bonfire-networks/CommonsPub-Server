import * as React from 'react';
import {
  Link as RouterLink,
  LinkProps as RouterLinkProps
} from 'react-router-dom';

import styled, { StyledThemeInterface } from '../../../themes/styled';

const Link = styled(RouterLink)<StyledThemeInterface>`
  &&,
  && a {
    color: ${props => props.theme.styles.colour.primary};

    &:hover,
    &.hover {
      color: ${props => props.theme.styles.colour.primaryAlt};
    }

    &:active,
    &.active {
      color: ${props => props.theme.styles.colour.primaryDark};
    }
  }
`;

type LinkProps = {
  hovered?: boolean;
  active?: boolean;
} & RouterLinkProps;

export default function({
  className = '',
  hovered,
  active,
  children,
  ...props
}: LinkProps) {
  className = `${className}${hovered ? ' hover' : ''}${
    active ? ' active' : ''
  }`;
  return (
    <Link className={className} {...props as any}>
      {children}
    </Link>
  );
}
