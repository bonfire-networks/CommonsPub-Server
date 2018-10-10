import styled, { withTheme, ThemeInterface } from '../../../themes/styled';

interface ColourBlockProps {
  theme: ThemeInterface;
  colour: string;
}

const ColourBlock = styled.div`
  float: left;
  colour: white;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 20px 20px 0;
  width: 125px;
  height: 125px;
  background-color: ${(props: ColourBlockProps) =>
    props.theme.styles.colour[props.colour]};
`;

export default withTheme(ColourBlock);
