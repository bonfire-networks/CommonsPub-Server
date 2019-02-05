import React from 'react';
import styled from '../../../themes/styled';
import { compose } from 'recompose';
import { graphql, OperationOption } from 'react-apollo';
const {
  joinCollectionMutation
} = require('../../../graphql/joinCollection.graphql');
const {
  undoJoinCollectionMutation
} = require('../../../graphql/undoJoinCollection.graphql');
import gql from 'graphql-tag';
import { Eye, Unfollow } from '../Icons';
import { Trans } from '@lingui/macro';

interface Props {
  joinCollection: any;
  leaveCollection: any;
  id: string;
  followed: boolean;
  externalId: string;
}

const withJoinCollection = graphql<{}>(joinCollectionMutation, {
  name: 'joinCollection'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const withLeaveCollection = graphql<{}>(undoJoinCollectionMutation, {
  name: 'leaveCollection'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const Join: React.SFC<Props> = ({
  joinCollection,
  id,
  leaveCollection,
  externalId,
  followed
}) => {
  if (followed) {
    return (
      <Span
        unfollow
        onClick={() =>
          leaveCollection({
            variables: { collectionId: id },
            update: (proxy, { data: { undoJoinCollection } }) => {
              const fragment = gql`
                fragment Res on Collection {
                  followed
                }
              `;
              let collection = proxy.readFragment({
                id: `Collection:${externalId}`,
                fragment: fragment,
                fragmentName: 'Res'
              });
              collection.followed = !collection.followed;
              proxy.writeFragment({
                id: `Collection:${externalId}`,
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
        <Unfollow width={18} height={18} strokeWidth={2} color={'#1e1f2480'} />
        <Trans>Unfollowing</Trans>
      </Span>
    );
  } else {
    return (
      <Span
        onClick={() =>
          joinCollection({
            variables: { collectionId: id },
            update: (proxy, { data: { joinCollection } }) => {
              const fragment = gql`
                fragment Res on Collection {
                  followed
                }
              `;
              let collection = proxy.readFragment({
                id: `Collection:${externalId}`,
                fragment: fragment,
                fragmentName: 'Res'
              });
              collection.followed = !collection.followed;
              proxy.writeFragment({
                id: `Collection:${externalId}`,
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
        <Eye width={18} height={18} strokeWidth={2} color={'#f98012'} />
        <Trans>Following</Trans>
      </Span>
    );
  }
};

const Span = styled.div<{ unfollow?: boolean }>`
  padding: 0px 10px;
  color: ${props =>
    props.unfollow ? '#1e1f2480' : props.theme.styles.colour.primaryAlt};
  height: 40px;
  font-weight: 600;
  font-size: 13px;
  line-height: 38px;
  cursor: pointer;
  text-align: center;
  border-radius: 100px;
  padding: 0 14px;
  &:hover {
    background: ${props => (props.unfollow ? '#1e1f241a' : '#fa973d20')};
  }
  & svg {
    margin-right: 8px;
    vertical-align: sub;
  }
`;

export default compose(
  withJoinCollection,
  withLeaveCollection
)(Join);
