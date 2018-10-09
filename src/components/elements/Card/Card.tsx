import * as React from 'react';

import styled from '../../../themes/styled';

import H4 from '../../typography/H4/H4';
import Button from '../Button/Button';

export const StyledCard = styled.div`
  background-color: white;
  padding: 15px;
  box-shadow: 0 0 3px lightgrey;
  border-radius: 5px;
  margin-bottom: 20px;
  border-top: 1px solid ${props => props.theme.styles.colour.primary};
`;

export type CardProps = {
  title: string;
};

const Card: React.SFC<CardProps> = ({ title }) => {
  return (
    <StyledCard>
      <H4>{title}</H4>
      <Button>View</Button>
    </StyledCard>
  );
};

export default Card;
