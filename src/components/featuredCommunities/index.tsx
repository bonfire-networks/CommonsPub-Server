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
import { ChevronLeft, Right } from '../elements/Icons';

export const Title = styled.div`
  font-size: 15px;
  font-weight: 700;
  padding: 8px;
  border-bottom: 1px solid ${props => props.theme.styles.colour.divider};
  margin: 0;
  margin-bottom: 8px;
  color: ${props => props.theme.styles.colour.base1};
  & h5 {
    margin: 0;
    color: ${props => props.theme.styles.colour.base1};
    display: inline-block;
    padding: 0;
    font-size: 16px;
    height: 30px;
    line-height: 30px;
  }
`;

export const RightContext = styled.div`
  & span {
    cursor: pointer;
    display: inline-block;
    height: 30px;
    & svg {
      color: ${props => props.theme.styles.colour.base1} !important;
      vertical-align: middle;
      height: 30px;
    }
    &:hover {
      & svg {
        color: ${props => props.theme.styles.colour.base1} !important;
      }
    }
  }
  float: right;
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
      slidesToScroll: 1
    };
    return (
      <>
        <Title>
          <h5>
            <Trans>Featured communities</Trans>{' '}
          </h5>
          <RightContext>
            <span onClick={this.previous}>
              <ChevronLeft
                width={26}
                height={26}
                strokeWidth={1}
                color={'#333'}
              />
            </span>
            <span onClick={this.next}>
              <Right width={26} height={26} strokeWidth={1} color={'#333'} />
            </span>
          </RightContext>
        </Title>
        {this.props.data.error ? (
          <span>
            <Trans>Error loading featured communities</Trans>
          </span>
        ) : this.props.data.loading ? (
          <Loader />
        ) : (
          <Slider ref={c => (this.slider = c)} {...settings}>
            <CommunitySmall collection={this.props.data.one} />
            <CommunitySmall collection={this.props.data.two} />
            <CommunitySmall collection={this.props.data.three} />
            <CommunitySmall collection={this.props.data.four} />
            <CommunitySmall collection={this.props.data.five} />
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
>(getFollowedCommunities, {
  options: {
    variables: {
      one:
        process.env.REACT_APP_GRAPHQL_ENDPOINT ===
        'https://home.moodle.net/api/graphql'
          ? 7
          : 834,
      two:
        process.env.REACT_APP_GRAPHQL_ENDPOINT ===
        'https://home.moodle.net/api/graphql'
          ? 15
          : 700,
      three:
        process.env.REACT_APP_GRAPHQL_ENDPOINT ===
        'https://home.moodle.net/api/graphql'
          ? 5774
          : 666,
      four:
        process.env.REACT_APP_GRAPHQL_ENDPOINT ===
        'https://home.moodle.net/api/graphql'
          ? 5030
          : 402,
      five:
        process.env.REACT_APP_GRAPHQL_ENDPOINT ===
        'https://home.moodle.net/api/graphql'
          ? 5018
          : 353
    }
  }
}) as OperationOption<{}, {}>;

export default compose(withGetInbox)(MultipleItems);
