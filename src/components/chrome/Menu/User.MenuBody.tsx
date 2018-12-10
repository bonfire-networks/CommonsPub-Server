import * as React from 'react';

import styled from '../../../themes/styled';
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
      <UserLink title="Go to Edit profile" to={`/user`}>
        <FontAwesomeIcon icon={faPencilAlt} /> &nbsp;Edit profile
      </UserLink>
      <br />
      <UserLink title="Go to Settings" to={`/settings`}>
        <FontAwesomeIcon icon={faCogs} /> &nbsp;Settings
      </UserLink>
      <br />
      <UserLink title="Sign out of MoodleNet" to={`/sign-out`}>
        <FontAwesomeIcon icon={faSignOutAlt} /> &nbsp;Sign out
      </UserLink>
    </UserMenu>
  );
};
