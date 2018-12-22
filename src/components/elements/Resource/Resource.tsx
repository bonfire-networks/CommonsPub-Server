import * as React from 'react';
import styled from '../../../themes/styled';
import H5 from '../../typography/H5/H5';
import P from '../../typography/P/P';
import { Link } from 'react-router-dom';

interface Props {
  icon: string;
  title: string;
  summary: string;
}

const ResourceCard: React.SFC<Props> = props => (
  <Wrapper>
    <Link to="">
      <Tags>
        <Tag>Autonomy</Tag>
      </Tags>
      <Img style={{ backgroundImage: `url(${props.icon})` }} />
      <Title>{props.title}</Title>
      <Summary>{props.summary}</Summary>
      <Actions />
    </Link>
  </Wrapper>
);

const Wrapper = styled.div`
  background: #fff;
  background-radius: 4px;
  border: 1px solid #eaeaea;
  padding: 8px;
  box-shadow: 0 2px 20px 0px rgba(0, 0, 0, 0.05);
  border-radius: 4px;
  & a {
    text-decoration: none;
    color: inherit;
  }
`;

const Tags = styled.div`
  height: 30px;
`;

const Tag = styled.div`
  display: inline-block;
  background: aliceblue;
  padding: 1px 10px;
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: #2d2e2ee6;
  border: 1px solid #2ccbff;
  border-radius: 100px;
`;

const Img = styled.div`
  margin-left: -8px;
  margin-right: -8px;
  background-size: cover;
  background-repeat: none;
  height: 140px;
  background-position: center center;
`;
const Title = styled(H5)`
  margin: 0 !important;
  font-size: 16px !important;
`;
const Summary = styled(P)`
  margin: 0 !important;
  margin-top: 4px;
`;
const Actions = styled.div``;

export default ResourceCard;
