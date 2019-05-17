import React from 'react';
import styled from '../../themes/styled';
import { Plus, Minus } from '../../components/elements/Icons';
import { compose } from 'recompose';
import { graphql, OperationOption } from 'react-apollo';
const {
  joinCommunityMutation
} = require('../../graphql/joinCommunity.graphql');
const {
  undoJoinCommunityMutation
} = require('../../graphql/undoJoinCommunity.graphql');
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
      <MinusBg>
        <Span
          onClick={() =>
            leaveCommunity({
              variables: { communityId: id },
              update: (proxy, { data: { undoJoinCommunity } }) => {
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
          <Minus width={16} height={16} strokeWidth={3} color={'#f98012'} />
        </Span>
      </MinusBg>
    );
  } else {
    return (
      <Span
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
        <Plus width={16} height={16} strokeWidth={2} color={'#f98012'} />
      </Span>
    );
  }
};

const MinusBg = styled.div`
  & svg {
    color: #fff !important;
  }
  & div {
    background: ${props => props.theme.styles.colour.primary} !important;
  }
`;

const Span = styled.div`
  color: ${props => props.theme.styles.colour.base2};
  cursor: pointer;
  text-align: center;
  border-radius: 3px;
  margin-left: 8px;
  box-sizing: border-box;
  box-shadow: 0 0 0 1px rgba(0, 0, 0, 0.05), 0 1px 2px rgba(0, 0, 0, 0.07);
  display: inline-block;
  padding: 0;
  min-width: 0;
  width: 32px;
  height: 32px;
  font-size: 16px;
  border-radius: 4px;
  line-height: 32px;
  position: absolute;
  top: 0px;
  right: 0;
  border: 2px solid ${props => props.theme.styles.colour.primary};
  &:hover {
    background: ${props => props.theme.styles.colour.newcommunityBgHover};
  }
  & svg {
    vertical-align: text-top;
    color: ${props => props.theme.styles.colour.primary};
  }
`;

export default compose(
  withJoinCommunity,
  withLeaveCommunity
)(Join);
