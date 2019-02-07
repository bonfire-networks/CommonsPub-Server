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

const { getCommunitiesQuery } = require('../../graphql/getCommunities.graphql');

interface Data extends GraphqlQueryControls {
  communities: Community[];
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
      body = this.props.data.communities.map((community, i) => {
        return (
          <CommunityCard
            key={i}
            summary={community.summary}
            title={community.name}
            icon={community.icon || ''}
            collectionsCount={community.collectionsCount}
            id={community.localId}
            followed={community.followed}
            followersCount={community.followersCount}
            externalId={community.id}
          />
        );
      });
    }
    return (
      <Main>
        <WrapperCont>
          <Wrapper>
            <H4>
              <Trans>Featured Communities</Trans>
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
  height: 100%;
  background: white;
  margin-top: 24px;
  border-radius: 4px;
`;

const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  flex: 1;
  margin-bottom: 24px;

  & h4 {
    padding-left: 8px;
    margin: 0;
    border-bottom: 1px solid #dadada;
    margin-bottom: 20px !important;
    line-height: 32px !important;
    background-color: #f5f6f7;
    border-bottom: 1px solid #dddfe2;
    border-radius: 2px 2px 0 0;
    font-weight: bold;
    font-size: 14px !important;
    color: #4b4f56;
  }
`;
const List = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  grid-column-gap: 16px;
  grid-row-gap: 16px;
  padding: 16px;
  background: white;
  padding-top: 0;
`;

const withGetCommunities = graphql<
  {},
  {
    data: {
      communities: Community[];
    };
  }
>(getCommunitiesQuery) as OperationOption<{}, {}>;

export default compose(withGetCommunities)(CommunitiesYours);
