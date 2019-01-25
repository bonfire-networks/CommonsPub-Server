import React from 'react';
import { compose } from 'recompose';
const { getUserQuery } = require('../../graphql/getUser.client.graphql');
import styled from '../../themes/styled';
import { graphql } from 'react-apollo';

interface Props {
  data: any;
}

const Home: React.SFC<Props> = props => (
  <Container>
    <Wrapper>
      <Title>👋 Welcome {props.data.user.data.name}!</Title>
      <p>
        Thanks for being part of this testing process for MoodleNet. <br />
        <Video>
          <iframe
            style={{
              border: 'none',
              padding: '5px',
              borderRadius: '0.25em',
              backgroundColor: 'rgb(232,232,232)'
            }}
            data-allowfullscreen
            width="600"
            height="337"
            scrolling="no"
            data-frameborder="0"
            src="https://www.wevideo.com/view/1290471043"
          />
        </Video>
        We’re trying to discover the answer to this question:
      </p>
      <blockquote>
        Do educators want to join communities to curate collections of
        resources?
      </blockquote>
      <p>
        During this testing period, we’ll observe what you choose to curate and
        comment in MoodleNet, and listening to what you tell us about your
        experiences.
        <br />
        Although you’re <b>one of only 100 people</b> who have an account to be
        involved in the initial testing of MoodleNet,{' '}
        <i>this isn’t a closed environment.</i>
        The resources you curate and the discussions you engage in are likely to
        live on and will be publicly viewable. <br />
        We’re using{' '}
        <a target="blank" href="https://changemap.co/moodle/moodlenet">
          Changemap
        </a>{' '}
        to collect your feedback during this test, so please do use that to
        suggest everything from small tweaks to major changes!
        <br />
        We’re really looking forward to seeing how you use MoodleNet to share
        and curate resources, and collaborate with other educators!
      </p>
      <Sign>
        <b>Doug, Mayel, Alex and Ivan</b> <br />
        <i>MoodleNet Team</i> <br />
      </Sign>
      <p>
        <u>
          PS. Don’t worry, we’re not tracking you! By ‘observe you’ we just mean
          checking out what you curate and comment on that others can see.
        </u>
      </p>
    </Wrapper>
  </Container>
);

const Container = styled.div`
  overflow: overlay;
`;
const Sign = styled.div`
  & b {
    margin-top: 40px;
    display: block;
    margin-bottom: 0;
  }

  & i {
    display: block;
    margin-top: -20px;
    font-weight: 700;
    color: #c1c1c1;
    font-style: normal;
    font-size: 14px;
    letter-spacing: 1px;
  }
`;
const Video = styled.div`
  margin: 16px 0;
`;
const Wrapper = styled.div`
  width: 620px;
  margin: 0 auto;
  margin-bottom: 40px;

  & a {
    color: #f98011;
    text-decoration: none;
    font-weight: 700;
    position: relative;
    &:before {
      position: absolute;
      content: '';
      left: 0;
      right: 0;
      width: 100%;
      height: 6px;
      bottom: 1px;
      background: #f9801182;
      display: block;
    }
  }
  & p {
    font-size: 16px;
    letter-spacing: 0;
    color: #3c3c3c;
    line-height: 30px;
  }
  & blockquote {
    font-size: 22px;
    font-weight: 600;
    border-left: 6px solid;
    padding-left: 20px;
    margin-left: 20px;
    color: #f98011;
  }

  & u {
    font-size: 14px;
  }
`;
const Title = styled.h1`
  font-size: 50px;
`;

export default compose(graphql(getUserQuery))(Home);
