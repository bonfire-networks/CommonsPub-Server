import React from 'react';
import { compose } from 'recompose';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import Slider from 'react-slick';
import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';
const getFollowedCollections = require('../../graphql/getFeaturedCollections.graphql');
import Loader from '../../components/elements/Loader/Loader';
import { Trans } from '@lingui/macro';
import CollectionSmall from '../elements/Collection/CollectionSmall';
import styled from '../../themes/styled';

const Title = styled.div`
  font-size: 15px;
  font-weight: 700;
  color: ${props => props.theme.styles.colour.base1};
  border-bottom: 1px solid #dddee447;
  padding-bottom: 8px;
  margin-bottom: 16px;
  margin-top: 16px;
`;

interface Data extends GraphqlQueryControls {
  one: any;
  two: any;
  three: any;
  four: any;
  five: any;
  six: any;
  seven: any;
  eight: any;
  nine: any;
  ten: any;
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
        <Trans>Featured collections</Trans>{' '}
      </Title>
      {props.data.error ? (
        <span>
          <Trans>Error loading featured collections</Trans>
        </span>
      ) : props.data.loading ? (
        <Loader />
      ) : (
        <Slider {...settings}>
          <CollectionSmall collection={props.data.one} />
          <CollectionSmall collection={props.data.two} />
          <CollectionSmall collection={props.data.three} />
          <CollectionSmall collection={props.data.four} />
          <CollectionSmall collection={props.data.five} />
          <CollectionSmall collection={props.data.six} />
          <CollectionSmall collection={props.data.seven} />
          <CollectionSmall collection={props.data.eight} />
          <CollectionSmall collection={props.data.nine} />
          <CollectionSmall collection={props.data.ten} />
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
>(getFollowedCollections) as OperationOption<{}, {}>;

export default compose(withGetInbox)(MultipleItems);
