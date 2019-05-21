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
import { ChevronLeft, Right } from '../elements/Icons';
import { Title, RightContext } from '../featuredCommunities';

interface Data extends GraphqlQueryControls {
  one: any;
  two: any;
  three: any;
  four: any;
  five: any;
  six: any;
  seven: any;
}

interface Props {
  data: Data;
}

class MultipleItems extends React.Component<Props> {
  private slider: any;

  constructor(props) {
    super(props);
    this.next = this.next.bind(this);
    this.previous = this.previous.bind(this);
  }
  next() {
    this.slider.slickNext();
  }
  previous() {
    this.slider.slickPrev();
  }
  render() {
    const settings = {
      dots: false,
      arrows: false,
      infinite: true,
      autoplay: false,
      speed: 500,
      slidesToShow: 5,
      slidesToScroll: 1,
      responsive: [
        {
          breakpoint: 1024,
          settings: {
            slidesToShow: 5,
            slidesToScroll: 1
          }
        },
        {
          breakpoint: 600,
          settings: {
            slidesToShow: 3,
            slidesToScroll: 1
          }
        },
        {
          breakpoint: 480,
          settings: {
            slidesToShow: 2,
            slidesToScroll: 1
          }
        }
      ]
    };
    return (
      <>
        <Title>
          <h5>
            <Trans>Featured collections</Trans>{' '}
          </h5>
          <RightContext>
            <span onClick={this.previous}>
              <ChevronLeft
                width={26}
                height={26}
                strokeWidth={1}
                color={'inherit'}
              />
            </span>
            <span onClick={this.next}>
              <Right width={26} height={26} strokeWidth={1} color={'inherit'} />
            </span>
          </RightContext>
        </Title>
        {this.props.data.error ? (
          <span>
            <Trans>Error loading featured collections</Trans>
          </span>
        ) : this.props.data.loading ? (
          <Loader />
        ) : (
          <Slider ref={c => (this.slider = c)} {...settings}>
            <CollectionSmall collection={this.props.data.one} />
            <CollectionSmall collection={this.props.data.two} />
            <CollectionSmall collection={this.props.data.three} />
            <CollectionSmall collection={this.props.data.four} />
            <CollectionSmall collection={this.props.data.five} />
            <CollectionSmall collection={this.props.data.six} />
            <CollectionSmall collection={this.props.data.seven} />
          </Slider>
        )}
      </>
    );
  }
}

const withGetInbox = graphql<
  {},
  {
    data: any;
  }
>(getFollowedCollections, {
  options: {
    variables: {
      one:
        process.env.REACT_APP_GRAPHQL_ENDPOINT ===
        'https://home.moodle.net/api/graphql'
          ? 2510
          : 4944,
      two:
        process.env.REACT_APP_GRAPHQL_ENDPOINT ===
        'https://home.moodle.net/api/graphql'
          ? 2374
          : 5416,
      three:
        process.env.REACT_APP_GRAPHQL_ENDPOINT ===
        'https://home.moodle.net/api/graphql'
          ? 5487
          : 5571,
      four:
        process.env.REACT_APP_GRAPHQL_ENDPOINT ===
        'https://home.moodle.net/api/graphql'
          ? 8092
          : 5487,
      five:
        process.env.REACT_APP_GRAPHQL_ENDPOINT ===
        'https://home.moodle.net/api/graphql'
          ? 690
          : 4944,
      six:
        process.env.REACT_APP_GRAPHQL_ENDPOINT ===
        'https://home.moodle.net/api/graphql'
          ? 3790
          : 2374,
      seven:
        process.env.REACT_APP_GRAPHQL_ENDPOINT ===
        'https://home.moodle.net/api/graphql'
          ? 4848
          : 5571
    }
  }
}) as OperationOption<{}, {}>;

export default compose(withGetInbox)(MultipleItems);
