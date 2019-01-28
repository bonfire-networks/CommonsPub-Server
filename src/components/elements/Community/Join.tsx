import React from 'react';
import styled from '../../../themes/styled';
import { Preferites } from '../Icons';
import { compose } from 'recompose';
import { graphql, OperationOption } from 'react-apollo';
const {
  joinCommunityMutation
} = require('../../../graphql/joinCommunity.graphql');

interface Props {
  joinCommunity: any;
  id: string;
}

const withJoinCommunity = graphql<{}>(joinCommunityMutation, {
  name: 'joinCommunity'
  // TODO enforce proper types for OperationOption
} as OperationOption<{}, {}>);

const Join: React.SFC<Props> = ({ joinCommunity, id }) => (
  <Span
    onClick={() =>
      joinCommunity({
        variables: { communityId: id },
        update: (store, { data }) => {}
      })
        .then(res => {
          console.log(res);
        })
        .catch(err => console.log(err))
    }
  >
    <Preferites width={32} height={32} strokeWidth={1} color={'#f0f0f0'} />
  </Span>
);

const Span = styled.div`
  text-align: center;
  border-radius: 100px;
  width: 50px;
  height: 50px;
  text-align: center;
  cursor: pointer;
  margin: 0 auto;
  margin-top: 80px;
  & svg {
    margin-top: 8px;
    text-align: center;
  }
  &:hover  {
    background: rgba(0, 0, 0, 0.7);
  }
`;

export default compose(withJoinCommunity)(Join);
