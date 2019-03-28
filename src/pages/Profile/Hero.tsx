import React, { SFC } from 'react';
import styled from '../../themes/styled';
import P from '../../components/typography/P/P';
import H2 from '../../components/typography/H2/H2';

interface Props {
  user: {
    name: string;
    summary: string;
    icon: string;
  };
}

const HeroComp: SFC<Props> = ({ user }) => (
  <HeroCont>
    <Hero>
      <WrapperHero>
        <Img
          style={{
            backgroundImage: `url(${user.icon})`
          }}
        />
        <HeroInfo>
          <H2>{user.name}</H2>
          <P>{user.summary}</P>
        </HeroInfo>
      </WrapperHero>
    </Hero>
  </HeroCont>
);

export default HeroComp;

const WrapperHero = styled.div`
  padding: 24px;
  padding-top: 0;
  z-index: 9999;
  position: relative;
  text-align: center;
`;

const Img = styled.div`
  width: 120px;
  height: 120px;
  border-radius: 100px;
  background: antiquewhite;
  border: 5px solid white;
  margin: 0 auto;
  margin-bottom: 10px;
  background-size: cover;
  background-position: center center;
  background-repeat: no-repeat;
`;

const HeroCont = styled.div`
  margin-bottom: 16px;
  box-sizing: border-box;
  margin-top: 24px;
`;

const Hero = styled.div`
  width: 100%;
  position: relative;
`;

const HeroInfo = styled.div`
  & h2 {
    margin: 0;
    font-size: 24px !important;
    line-height: 40px !important;
    margin-bottom: 16px;
  }

  & button {
    span {
      vertical-align: sub;
      display: inline-block;
      height: 30px;
      margin-right: 4px;
    }
  }
`;
