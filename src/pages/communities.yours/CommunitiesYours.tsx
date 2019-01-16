import * as React from 'react';
import compose from 'recompose/compose';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';

import { Trans } from '@lingui/macro';

import { Col, Grid, Row } from '@zendeskgarden/react-grid';
import H1 from '../../components/typography/H1/H1';
import P from '../../components/typography/P/P';
import styled from 'styled-components';
import Logo from '../../components/brand/Logo/Logo';
import Main from '../../components/chrome/Main/Main';
import Community from '../../types/Community';
import Loader from '../../components/elements/Loader/Loader';
import { CommunityCard } from '../../components/elements/Card/Card';

const { getCommunitiesQuery } = require('../../graphql/getCommunities.graphql');

const PageTitle = styled(H1)`
  font-size: 30px !important;
  margin-block-start: 0;
  margin-block-end: 0;
`;

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
      body = this.props.data.communities.map(community => {
        return (
          <CommunityCard
            key={community.id}
            onButtonClick={() => alert('card btn clicked')}
            entity={community}
          />
        );
      });
    }

    return (
      <Main>
        <Grid>
          <Row>
            <Col sm={6}>
              <Logo />
              <PageTitle>
                <Trans>Your Communities</Trans>
              </PageTitle>
            </Col>
          </Row>
          <Row>
            <Col size={6}>
              <P>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit.
                Vestibulum ornare pretium tellus ut laoreet. Donec nec pulvinar
                diam. Fusce sed est sed sem condimentum porttitor eget non
                turpis. Sed dictum pulvinar dui, iaculis ultrices orci
                scelerisque non. Integer a dignissim arcu. Nunc eu mi orci.
                Fusce ante sapien, elementum in gravida ut, porta ut erat.
                Suspendisse potenti.
              </P>
            </Col>
          </Row>
          <Row>
            <Col size={10} style={{ display: 'flex', flexWrap: 'wrap' }}>
              {body}
            </Col>
          </Row>
        </Grid>
      </Main>
    );
  }
}

const withGetCommunities = graphql<
  {},
  {
    data: {
      communities: Community[];
    };
  }
>(getCommunitiesQuery) as OperationOption<{}, {}>;

export default compose(withGetCommunities)(CommunitiesYours);
