import styled from '../../themes/styled';

interface PreviousStepProps {
  theme?: object;
  active: boolean;
}

const PreviousStep = styled.div<PreviousStepProps>`
  position: absolute;
  color: ${props => props.theme.styles.colour.primary};
  font-weight: bold;
  font-size: 1.5rem;
  cursor: pointer;
  padding: 10px;
  top: -4px;
  left: ${props => (props.active ? -23 : -15)}px;
  opacity: ${props => (props.active ? 1 : 0)};
  transition: all 0.2s linear;
`;

export default PreviousStep;
