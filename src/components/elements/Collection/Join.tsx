import React from 'react';
import styled from '../../../themes/styled';
import { Preferites } from '../Icons';
import { compose } from 'recompose';
import { graphql, OperationOption } from 'react-apollo';
const {
  joinCollectionMutation
} = require('../../../graphql/joinCollection.graphql');
const {
  undoJoinCollectionMutation
} = require('../../../graphql/undoJoinCollection.graphql');
import { Trans } from '@lingui/macro';
import gql from 'graphql-tag';

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
        onClick={() =>
          leaveCollection({
            variables: { collectionId: id },
            update: (proxy, { data: { undoJoinCollection } }) => {
              const fragment = gql`
                fragment Res on Collection {
                  followed
                }
              `;
              console.log(proxy);
              let collection = proxy.readFragment({
                id: `Collection:${externalId}`,
                fragment: fragment,
                fragmentName: 'Res'
              });
              console.log(collection);
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
        <Trans>Unfollow</Trans>
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
        <Preferites
          width={16}
          height={16}
          strokeWidth={2}
          color={'#1e1f2480'}
        />
        <Trans>Follow</Trans>
      </Span>
    );
  }
};

const Span = styled.div`
  padding: 0px 10px;
  color: #1e1f2480;
  height: 40px;
  font-weight: 600;
  line-height: 40px;
  cursor: pointer;
  text-align: center;
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
  withJoinCollection,
  withLeaveCollection
)(Join);
