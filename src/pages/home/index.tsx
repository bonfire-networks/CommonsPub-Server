import React from 'react';
import { compose } from 'recompose';
const { getUserQuery } = require('../../graphql/getUser.client.graphql');
import styled from '../../themes/styled';
import { graphql } from 'react-apollo';
import media from 'styled-media-query';
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
        <Trans>Thank you for helping out by testing MoodleNet.</Trans>{' '}
        <Trans>
          We’ve{' '}
          <a href="https://blog.moodle.net/2019/what-we-learned-from-testing/">
            successfully concluded the testing period
          </a>{' '}
          and are currently working on features and improvements to get
          MoodleNet ready to move from ‘alpha’ to ‘beta’.
        </Trans>
      </p>

      <p>
        <Trans>Here are some important things to note:</Trans>
      </p>

      <ol>
        <li>
          <Trans>
            Your use of MoodleNet is subject to the
            <a href="https://docs.moodle.org/dev/MoodleNet/Code_of_Conduct">
              Code of Conduct
            </a>
            .
          </Trans>
        </li>
        <li>
          <Trans>
            Although we’re keeping MoodleNet invite-only at the moment, soon
            anyone on the internet will be able to view the communities and
            collections you create, the resources you add, and the discussions
            you engage in.
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
            We’re still using{' '}
            <a href="https://changemap.co/moodle/moodlenet">Changemap</a> to
            collect your feedback, so please use it to suggest everything from
            small tweaks to major changes! You can access this using the{' '}
            <a href="https://changemap.co/moodle/moodlenet">Share feedback</a>{' '}
            link in the sidebar.
          </Trans>
        </li>
      </ol>
      <p>
        <Trans>
          We’re busy working on the roadmap, with the most important next step
          being federation (i.e. the ability to have separate instances of
          MoodleNet that can communicate with one another).
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

const Container = styled.div`
  overflow-y: scroll;
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
// const Video = styled.div`
//   margin: 16px auto;
//   text-align: center;
// `;
const Wrapper = styled.div`
  width: 620px;
  margin: 0 auto;
  margin-bottom: 40px;
  ${media.lessThan('medium')`
  width: auto;
  padding: 8px;
`};
  & a {
    color: #f98011;
    text-decoration: none;
    font-weight: 700;
    position: relative;
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
