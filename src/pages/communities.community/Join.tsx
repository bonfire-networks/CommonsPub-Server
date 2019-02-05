import React from 'react';
import styled from '../../themes/styled';
import { Preferites } from '../../components/elements/Icons';
import { compose } from 'recompose';
import Button from '../../components/elements/Button/Button';
import { graphql, OperationOption } from 'react-apollo';
const {
  joinCommunityMutation
} = require('../../graphql/joinCommunity.graphql');
const {
  undoJoinCommunityMutation
} = require('../../graphql/undoJoinCommunity.graphql');
import { Trans } from '@lingui/macro';
import gql from 'graphql-tag';

interface Props {
  joinCommunity: any;
  leaveCommunity: any;
  id: string;
  followed: boolean;
  externalId: string;
}

const withJoinCommunity = graphql<{}>(joinCommunityMutation, {
  name: 'joinCommunity'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const withLeaveCommunity = graphql<{}>(undoJoinCommunityMutation, {
  name: 'leaveCommunity'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const Join: React.SFC<Props> = ({
  joinCommunity,
  id,
  leaveCommunity,
  externalId,
  followed
}) => {
  if (followed) {
    return (
      <Span
        hovered
        onClick={() =>
          leaveCommunity({
            variables: { communityId: id },
            update: (proxy, { data: { undoJoinCommunity } }) => {
              const fragment = gql`
                fragment Res on Community {
                  followed
                }
              `;
              console.log(proxy);
              let collection = proxy.readFragment({
                id: `Community:${externalId}`,
                fragment: fragment,
                fragmentName: 'Res'
              });
              console.log(collection);
              collection.followed = !collection.followed;
              proxy.writeFragment({
                id: `Community:${externalId}`,
                fragment: fragment,
                fragmentName: 'Res',
                data: collection
              });
            }
          })
            .then(res => {
              console.log(res);
            })
            .catch(err => console.log(err))
        }
      >
        <Trans>Leave Community</Trans>
      </Span>
    );
  } else {
    return (
      <Span
        hovered
        onClick={() =>
          joinCommunity({
            variables: { communityId: id },
            update: (proxy, { data: { joinCommunity } }) => {
              const fragment = gql`
                fragment Res on Community {
                  followed
                }
              `;
              let collection = proxy.readFragment({
                id: `Community:${externalId}`,
                fragment: fragment,
                fragmentName: 'Res'
              });
              collection.followed = !collection.followed;
              proxy.writeFragment({
                id: `Community:${externalId}`,
                fragment: fragment,
                fragmentName: 'Res',
                data: collection
              });
            }
          })
            .then(res => {
              console.log(res);
            })
            .catch(err => console.log(err))
        }
      >
        <Preferites width={16} height={16} strokeWidth={2} color={'#f98012'} />
        <Trans>Join Community</Trans>
      </Span>
    );
  }
};

const Span = styled(Button)`
  color: #1e1f2480;
  font-weight: 600;
  cursor: pointer;
  text-align: center;
  border-radius: 100px !important;
  &:hover {
    color: ${props => props.theme.styles.colour.primaryAlt};
    & svg {
      color: ${props => props.theme.styles.colour.primaryAlt};
    }
  }
  & svg {
    margin-right: 8px;
    vertical-align: sub;
  }
`;

export default compose(
  withJoinCommunity,
  withLeaveCommunity
)(Join);
