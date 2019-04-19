import React from 'react';
import { compose } from 'recompose';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import Slider from 'react-slick';
import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';
const getFollowedCommunities = require('../../graphql/getFeaturedCommunities.graphql');
import Loader from '../../components/elements/Loader/Loader';
import { Trans } from '@lingui/macro';
import CommunitySmall from '../elements/Community/CommunitySmall';
import styled from '../../themes/styled';

const Title = styled.div`
  font-size: 15px;
  font-weight: 700;
  color: ${props => props.theme.styles.colour.base1};
  padding-bottom: 8px;
  margin-bottom: 16px;
  margin-top: 32px;
`;

interface Data extends GraphqlQueryControls {
  one: any;
  two: any;
  three: any;
  four: any;
  five: any;
}

interface Props {
  data: Data;
}

const MultipleItems = (props: Props) => {
  const settings = {
    dots: false,
    arrows: true,
    infinite: true,
    autoplay: false,
    speed: 500,
    slidesToShow: 4,
    slidesToScroll: 1
  };
  return (
    <>
      <Title>
        <Trans>Featured communities</Trans>{' '}
      </Title>
      {props.data.error ? (
        <span>
          <Trans>Error loading featured communities</Trans>
        </span>
      ) : props.data.loading ? (
        <Loader />
      ) : (
        <Slider {...settings}>
          <CommunitySmall collection={props.data.one} />
          <CommunitySmall collection={props.data.two} />
          <CommunitySmall collection={props.data.three} />
          <CommunitySmall collection={props.data.four} />
          <CommunitySmall collection={props.data.five} />
        </Slider>
      )}
    </>
  );
};

const withGetInbox = graphql<
  {},
  {
    data: any;
  }
>(getFollowedCommunities) as OperationOption<{}, {}>;

export default compose(withGetInbox)(MultipleItems);
