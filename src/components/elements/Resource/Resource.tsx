import * as React from 'react';
import styled from '../../../themes/styled';
import H5 from '../../typography/H5/H5';
import P from '../../typography/P/P';

interface Props {
  icon: string;
  title: string;
  summary: string;
  url: string;
}

const ResourceCard: React.SFC<Props> = props => (
  <Wrapper>
    <Img style={{ backgroundImage: `url(${props.icon})` }} />
    <Info>
      <Title>{props.title}</Title>
      <Url>
        <a target="blank" href={props.url}>
          {props.url}
        </a>
      </Url>
      <Summary>{props.summary}</Summary>
    </Info>
    <Actions />
  </Wrapper>
);

const Info = styled.div`
  flex: 1;
  margin-left: 16px;
`;
const Url = styled.div`
  margin-bottom: 8px;
  & a {
    font-size: 14px;
    color: #9e9e9e;
    font-weight: 500;
    text-decoration: none;
    &:hover {
      text-decoration: underline;
    }
  }
`;

const Wrapper = styled.div`
  background: #fff;
  background-radius: 4px;
  border: 1px solid rgba(0, 0, 0, 0.15);
  padding: 24px;
  border-radius: 4px;
  display: flex;
  margin-bottom: 8px;
`;

const Img = styled.div`
  background-size: cover;
  background-repeat: none;
  height: 80px;
  width: 80px;
  border-radius: 2px;
  background-position: center center;
`;
const Title = styled(H5)`
  margin: 0 !important;
  font-size: 16px !important;
  line-height: 16px !important;
  margin-top: 8px;
`;
const Summary = styled(P)`
  margin: 0 !important;
  margin-top: 4px;
  color: #757575;
  font-size: 14px;
`;
const Actions = styled.div``;

export default ResourceCard;
