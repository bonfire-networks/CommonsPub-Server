import React, { SFC } from 'react';
import styled from '../../themes/styled';
import P from '../../components/typography/P/P';
import H2 from '../../components/typography/H2/H2';
import { Helmet } from 'react-helmet';
import { Globe } from '../../components/elements/Icons';
interface Props {
  user: {
    name: string;
    summary: string;
    icon: string;
    preferredUsername: string;
    location: string;
  };
}

const HeroComp: SFC<Props> = ({ user }) => (
  <HeroCont>
    <Helmet>
      <title>MoodleNet > Profile > {user.name}</title>
    </Helmet>
    <Hero>
      <HeroBg />
      <WrapperHero>
        <Img
          style={{
            backgroundImage: `url(${user.icon})`
          }}
        />
        <HeroInfo>
          <H2>{user.name}</H2>
          <PreferredUsername>@{user.preferredUsername}</PreferredUsername>
        </HeroInfo>
      </WrapperHero>
      <P>{user.summary}</P>
      {user.location ? (
        <Location>
          <span>
            <Globe width={20} height={20} strokeWidth={1} color={'#333'} />
          </span>
          {user.location}
        </Location>
      ) : null}
    </Hero>
  </HeroCont>
);

export default HeroComp;

const PreferredUsername = styled.div`
  color: #fff;
  opacity: 0.6;
  font-weight: 600;
`;

const Location = styled.div`
  color: ${props => props.theme.styles.colour.heroIcon};
  opacity: 0.6;
  font-weight: 600;
  padding: 0 24px;
  padding-bottom: 0px;
  margin-left: 120px;
  margin: 0;
  margin-top: 0px;
  margin-left: 0px;
  margin-left: 136px;
  line-height: 26px;
  font-size: 16px;
  padding-bottom: 16px;
  span {
    display: inline-block;
    margin-right: 8px;
    & svg {
      color: ${props => props.theme.styles.colour.heroIcon};
      vertical-align: text-bottom;
    }
  }
`;

const HeroBg = styled.div`
  height: 250px;
  background: #333;
  border-top-right-radius: 6px;
  border-top-left-radius: 6px;
  background-image: url(https://images.unsplash.com/photo-1557943978-bea7e84f0e87?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60);
  background-position: center center;
  background-repeat: no-repeat;
  background-size: cover;
`;

const WrapperHero = styled.div`
  padding: 24px;
  padding-top: 0;
  z-index: 9999;
  position: relative;
  margin-top: -80px;
  padding-bottom: 0;
`;

const Img = styled.div`
  width: 120px;
  height: 120px;
  border-radius: 100px;
  background: ${props => props.theme.styles.colour.secondary};
  border: 5px solid white;
  margin-bottom: 10px;
  background-size: cover;
  background-position: center center;
  background-repeat: no-repeat;
  display: inline-block;
  vertical-align: middle;
  margin-right: 16px;
`;

const HeroCont = styled.div`
  margin-bottom: 16px;
  box-sizing: border-box;
  margin-top: 24px;
`;

const Hero = styled.div`
  width: 100%;
  position: relative;
  border-radius: 6px;
  background: ${props => props.theme.styles.colour.hero};
  & p {
    color: ${props => props.theme.styles.colour.heroNote};
    padding: 0 24px;
    margin-left: 120px;
    margin: 0;
    margin-left: 136px;
    margin-top: -40px;
    line-height: 26px;
    font-size: 16px;
    padding-bottom: 16px;
  }
`;

const HeroInfo = styled.div`
  display: inline-block;
  & h2 {
    margin: 0;
    font-size: 24px !important;
    line-height: 40px !important;
    margin-bottom: 0px;
    text-shadow: 0 1px #0005;
    color: #fff;
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
