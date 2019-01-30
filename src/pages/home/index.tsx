import React from 'react';
import { compose } from 'recompose';
const { getUserQuery } = require('../../graphql/getUser.client.graphql');
import styled from '../../themes/styled';
import { graphql } from 'react-apollo';

import { Trans } from '@lingui/macro';

interface Props {
  data: any;
}

const Home: React.SFC<Props> = props => (
  <Container>
    <Wrapper>
      <Title>
        👋 <Trans>Welcome</Trans>{' '}
        {props.data.user.data ? props.data.user.data.name : ''}!
      </Title>
      <p>
        <Trans>
          Thanks for being part of this testing process for MoodleNet.
        </Trans>
        <br />
        <Trans>
          Please pay attention to the video and text on this page, as they
          contain some important information.
        </Trans>
      </p>
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
          src="https://www.youtube-nocookie.com/embed/6fyrcm4N2CI?cc_load_policy=1"
          data-allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
        />
      </Video>
      <p>
        <Trans>We’re trying to discover the answer to this question:</Trans>
      </p>
      <blockquote>
        <Trans>
          Do educators want to join communities to curate collections of
          resources?
        </Trans>
      </blockquote>

      <p>
        <Trans>Here are some important things to note:</Trans>
      </p>

      <ol>
        <li>
          <Trans>
            Your involvement in the testing process is subject to the{' '}
            <a href="https://docs.moodle.org/dev/MoodleNet/Code_of_Conduct">
              Code of Conduct
            </a>
            .
          </Trans>
        </li>
        <li>
          <Trans>
            During this testing period we will observe what you do with
            MoodleNet, and listen to what you tell us about your experiences.
          </Trans>
        </li>
        <li>
          <Trans>
            You cannot completely delete anything in MoodleNet at the moment, as
            we have not rolled out the moderation tools. Instead, just change
            all of the fields within the resource to something else!
          </Trans>
        </li>
        <li>
          <Trans>
            This test is semi-closed, but your contributions will live on beyond
            the testing period. So curate and comment as if everything you share
            is public.
          </Trans>
        </li>
        <li>
          <Trans>
            We’re using{' '}
            <a href="https://changemap.co/moodle/moodlenet">Changemap</a> to
            collect your feedback during this testing period, so please do use
            that to suggest everything from small tweaks to major changes! You
            can access this using the ‘Share feedback’ link in the sidebar:
          </Trans>
          <Feedback target="blank" href="https://changemap.co/moodle/moodlenet">
            🔬 <Trans>Share Feedback</Trans>
          </Feedback>
        </li>
      </ol>
      <p>
        <Trans>
          We’re really looking forward to seeing how you use MoodleNet to share
          and curate resources, and collaborate with other educators! Get
          started by clicking on ‘The Lounge’ in the sidebar and introducing
          yourself, or by adding your first resource!
        </Trans>
      </p>
      <Sign>
        <b>Doug, Mayel, Alex & Ivan</b> <br />
        <i>
          <Trans>MoodleNet Team</Trans>
        </i>
      </Sign>
    </Wrapper>
  </Container>
);

const Feedback = styled.a`
  display: block;
  text-align: center;
  animation: 0.5s slide-in;
  position: relative;
  height: 30px;
  background: rgb(255, 239, 217);
  border-bottom: 1px solid rgb(228, 220, 195);
  color: #10100cc2 !important;
  line-height: 30px;
  padding: 0;
  font-size: 13px;
  text-decoration: none;
  font-size: 13px;
  font-weight: 700;
  margin-top: 8px;
  cursor: pointer;
  &:hover {
    background: rgb(245, 229, 207);
  }
  max-width: 200px;
`;

const Container = styled.div`
  overflow: scroll;
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
    // font-size: 14px;
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
  & p,
  & li {
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
