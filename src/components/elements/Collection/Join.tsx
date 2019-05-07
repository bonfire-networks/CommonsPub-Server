import React from 'react';
import styled from '../../../themes/styled';
import { compose, withState } from 'recompose';
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
import Loader from '../Loader/Loader';

interface Props {
  joinCollection: any;
  leaveCollection: any;
  id: string;
  followed: boolean;
  externalId: string;
  isSubmitting: boolean;
  onSubmitting: any;
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
  followed,
  isSubmitting,
  onSubmitting
}) => {
  if (followed) {
    return (
      <Span
        unfollow
        onClick={() => {
          onSubmitting(true);
          return leaveCollection({
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
              onSubmitting(false);
            })
            .catch(err => console.log(err));
        }}
      >
        {isSubmitting ? (
          <Loader />
        ) : (
          <>
            <Unfollow
              width={18}
              height={18}
              strokeWidth={2}
              color={'#1e1f2480'}
            />
            <Trans>Unfollow</Trans>
          </>
        )}
      </Span>
    );
  } else {
    return (
      <Span
        onClick={() => {
          onSubmitting(true);
          return joinCollection({
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
              onSubmitting(false);
            })
            .catch(err => console.log(err));
        }}
      >
        {isSubmitting ? (
          <Loader />
        ) : (
          <>
            <span>
              <Eye width={18} height={18} strokeWidth={2} color={'#f98012'} />
            </span>
            <Trans>Follow</Trans>
          </>
        )}
      </Span>
    );
  }
};

const Span = styled.div<{ unfollow?: boolean }>`
  color: ${props =>
    props.unfollow
      ? props => props.theme.styles.colour.heroCollectionIcon
      : props.theme.styles.colour.heroCollectionIcon};
  // height: 40px;
  font-weight: 600;
  font-size: 13px;
  line-height: 20px;
  cursor: pointer;
  text-align: center;
  border-radius: 3px;
  padding: 10px;
  border: 1px solid
    ${props =>
      props.unfollow
        ? props => props.theme.styles.colour.heroCollectionIcon
        : props.theme.styles.colour.heroCollectionIcon};
  &:hover {
    color: ${props =>
      props.unfollow
        ? props => props.theme.styles.colour.heroCollectionIcon
        : props.theme.styles.colour.base6};
    background: ${props =>
      props.unfollow ? '#1e1f241a' : props.theme.styles.colour.primary};
  }
  & span {
    display: block;
    vertical-align: middle;
    text-align: center;
  }
  & svg {
    vertical-align: sub;
    color: inherit !important;
  }
`;

export default compose(
  withJoinCollection,
  withLeaveCollection,
  withState('isSubmitting', 'onSubmitting', false)
)(Join);
