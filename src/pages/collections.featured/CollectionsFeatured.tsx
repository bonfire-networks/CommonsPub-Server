import * as React from 'react';
import compose from 'recompose/compose';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';

import { Trans } from '@lingui/macro';

import H4 from '../../components/typography/H4/H4';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
import Community from '../../types/Community';
import Loader from '../../components/elements/Loader/Loader';
import CollectionCard from '../../components/elements/Collection/Collection';

const { getCollectionsQuery } = require('../../graphql/getCollections.graphql');

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
          <Trans>Error loading collections</Trans>
        </span>
      );
    } else if (this.props.data.loading) {
      body = <Loader />;
    } else {
      body = this.props.data.communities.map(comm => {
        return comm.collections.map((coll, i) => (
          <CollectionCard
            key={i}
            collection={coll}
            communityId={comm.localId}
          />
        ));
      });
    }
    console.log(body);
    return (
      <Main>
        <Wrapper>
          <H4>
            <Trans>All Collections</Trans>
          </H4>
          <List>{body}</List>
        </Wrapper>
      </Main>
    );
  }
}

const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  flex: 1;
  margin-bottom: 24px;
  & h4 {
    font-size: 18px !important;
    margin: 0;
    border-bottom: 1px solid #dadada;
    margin-bottom: 20px !important;
    line-height: 32px !important;
  }
`;
const List = styled.div`
  display: grid;
  grid-template-columns: 1fr;
  grid-column-gap: 16px;
  grid-row-gap: 16px;
`;

const withGetCommunities = graphql<
  {},
  {
    data: {
      communities: Community[];
    };
  }
>(getCollectionsQuery) as OperationOption<{}, {}>;

export default compose(withGetCommunities)(CommunitiesYours);
