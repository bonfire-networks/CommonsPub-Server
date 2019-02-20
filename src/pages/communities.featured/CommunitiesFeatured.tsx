import * as React from 'react';
import compose from 'recompose/compose';
import { graphql, OperationOption } from 'react-apollo';

import { Trans } from '@lingui/macro';
import H4 from '../../components/typography/H4/H4';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
// import Community from '../../types/Community';
import Loader from '../../components/elements/Loader/Loader';
import CommunityCard from '../../components/elements/Community/Community';

const getCommunitiesQuery = require('../../graphql/getFeaturedCommunities.graphql');

// interface Data extends GraphqlQueryControls {
//   communities: Community[];
// }

interface Props {
  data: any;
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
      body = [];
      if (this.props.data.elsalon && this.props.data.thelounge) {
        body.push(
          <CommunityCard
            summary={this.props.data.elsalon.summary}
            title={this.props.data.elsalon.name}
            icon={this.props.data.elsalon.icon || ''}
            collectionsCount={this.props.data.elsalon.collectionsCount}
            id={this.props.data.elsalon.localId}
            followed={this.props.data.elsalon.followed}
            followersCount={this.props.data.elsalon.followersCount}
            externalId={this.props.data.elsalon.id}
          />
        );
        body.push(
          <CommunityCard
            summary={this.props.data.thelounge.summary}
            title={this.props.data.thelounge.name}
            icon={this.props.data.thelounge.icon || ''}
            collectionsCount={this.props.data.thelounge.collections.totalCount}
            id={this.props.data.thelounge.localId}
            followed={this.props.data.thelounge.followed}
            followersCount={this.props.data.thelounge.members.totalCount}
            externalId={this.props.data.thelounge.id}
          />
        );
      }
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
    data: any;
  }
>(getCommunitiesQuery) as OperationOption<{}, {}>;

export default compose(withGetCommunities)(CommunitiesYours);
