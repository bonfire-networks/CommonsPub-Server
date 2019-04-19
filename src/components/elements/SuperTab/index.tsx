import { Tab, TabList } from 'react-tabs';
import media from 'styled-media-query';
import styled from '../../../themes/styled';
import 'react-tabs/style/react-tabs.css';

export const SuperTabList = styled(TabList)`
  list-style: none;
  padding: 0;
  margin: 0;
  border-bottom: 1px solid ${props => props.theme.styles.colour.divider};
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  grid-column-gap: 32px;
  ${media.lessThan('medium')`
    grid-template-columns: 1fr 1fr 1fr
  `};
`;
export const SuperTab = styled(Tab)`
  border-radius: 0;
  border: none;
  position: relative;
  height: 40px;
  padding: 0 16px;
  color: #a0a2a5;
  background: transparent;
  cursor: pointer;
  text-align: center;
  & h5 {
    display: inline-block;
    color: #a0a2a5;
    font-size: 14px;
    font-weight: 600;
    line-height: 40px;
    margin: 0;
    ${media.lessThan('medium')`
display: none;
`};
  }

  & span {
    display: inline-block;
    margin-right: 8px;
    height: 40px;
    line-height: 40px;
    & svg {
      vertical-align: middle;
    }
  }
`;
