import * as React from 'react';

import styled from '../../../themes/styled';

import { Trans } from '@lingui/macro';

import Link from '../../elements/Link/Link';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
  faCogs,
  faPencilAlt,
  faSignOutAlt
} from '@fortawesome/free-solid-svg-icons';

const UserLink = styled(Link)`
  text-decoration: none;
`;

const UserMenu = styled.div`
  padding-top: 50px;
  text-align: center;
  font-size: 20px;

  a {
    display: inline-block;
    margin: 10px 0;
  }
`;

/**
 * The user's "User" menu that allows them to access their profile,
 * settings, and log out.
 * @param user {Object} the user object
 */
export default ({ user }) => {
  return (
    <UserMenu>
      <UserLink to={`/user`}>
        <FontAwesomeIcon icon={faPencilAlt} /> &nbsp;
        <Trans>Edit profile</Trans>
      </UserLink>
      <br />
      <UserLink to={`/settings`}>
        <FontAwesomeIcon icon={faCogs} /> &nbsp;
        <Trans>Settings</Trans>
      </UserLink>
      <br />
      <UserLink to={`/sign-out`}>
        <FontAwesomeIcon icon={faSignOutAlt} /> &nbsp;
        <Trans>Sign out</Trans>
      </UserLink>
    </UserMenu>
  );
};
