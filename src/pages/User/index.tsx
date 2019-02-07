import React from 'react';
import { compose } from 'recompose';
const { getUserQuery } = require('../../graphql/getUser.client.graphql');
import styled from '../../themes/styled';
import { graphql } from 'react-apollo';

// import { Trans } from '@lingui/macro';

interface Props {
  data: any;
}

const Home: React.SFC<Props> = props => (
  <Container>
    <Wrapper />
  </Container>
);

const Container = styled.div`
  overflow: scroll;
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

export default compose(graphql(getUserQuery))(Home);
