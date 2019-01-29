import * as React from 'react';
import compose from 'recompose/compose';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';

import { Trans } from '@lingui/macro';

import H4 from '../../components/typography/H4/H4';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
import Community from '../../types/Community';
import Loader from '../../components/elements/Loader/Loader';
import CommunityCard from '../../components/elements/Community/Community';

const {
  getJoinedCommunitiesQuery
} = require('../../graphql/getJoinedCommunities.graphql');

interface Data extends GraphqlQueryControls {
  followingCommunities: Community[];
}

interface Props {
  data: Data;
}

class CommunitiesYours extends React.Component<Props> {
  render() {
    let body;

    if (this.props.data.error) {
      body = (
        <span>
          <Trans>Error loading communities</Trans>
        </span>
      );
    } else if (this.props.data.loading) {
      body = <Loader />;
    } else {
      body = this.props.data.followingCommunities.map((community, i) => {
        return (
          <CommunityCard
            key={i}
            summary={community.summary}
            title={community.name}
            icon={community.icon || ''}
            followed={community.followed}
            id={community.localId}
            followersCount={community.followersCount}
          />
        );
      });
    }
    return (
      <Main>
        <WrapperCont>
          <Wrapper>
            <H4>
              <Trans>Joined Communities</Trans>
            </H4>
            <List>{body}</List>
          </Wrapper>
        </WrapperCont>
      </Main>
    );
  }
}

const WrapperCont = styled.div`
  max-width: 1040px;
  margin: 0 auto;
  width: 100%;
  background: white;
`;

const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  flex: 1;
  margin-bottom: 24px;
  & h4 {
    padding-left: 8px;
    font-size: 16px !important;
    margin: 0;
    border-bottom: 1px solid #dadada;
    margin-bottom: 20px !important;
    line-height: 32px !important;
  }
`;
const List = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  grid-column-gap: 16px;
  grid-row-gap: 16px;
  padding: 16px;
  padding-top: 0;
  background: white;
`;

const withGetCommunities = graphql<
  {},
  {
    data: {
      communities: Community[];
    };
  }
>(getJoinedCommunitiesQuery) as OperationOption<{}, {}>;

export default compose(withGetCommunities)(CommunitiesYours);
