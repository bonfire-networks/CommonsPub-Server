import React from 'react';
// import Icons from '../../atoms/icons.tsx'
import styled from 'styled-components';
import { clearFix } from 'polished';
import media from 'styled-media-query';
import { Cross } from '../Icons';
const Background = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(51, 60, 69, 0.95);
  z-index: 10000000;
  height: 100%;
  justify-content: center;
  overflow: auto;
  cursor: pointer;
`;

const Dialog = styled.div`
  width: 700px;
  box-shadow: 0 2px 8px 3px rgba(0, 0, 0, 0.3);
  z-index: 9999999999;
  background-color: #ffffff;
  padding: 0;
  margin: 40px auto;
  position: absolute;
  top: 20px;
  left: 50%;
  margin-left: -350px;
  border-radius: 3px;
  outline: none;

  ${media.lessThan('medium')`
    width: auto;
    margin: 0;
    left: 8px;
    right: 8px;
    top: 8px;
    // bottom: 8px;
  `};
`;

const Action = styled.div`
  ${clearFix()};
  padding-top: 10px;
  padding-right: 10px;
  float: right;
`;

const Close = styled.div`
  float: right;
  cursor: pointer;
`;

const Content = styled.div`
  ${clearFix()};
`;

export const Container = styled.div`
  font-family: ${props => props.theme.styles.fontFamily};
`;
export const Actions = styled.div`
  ${clearFix()};
  height: 60px;
  padding-top: 10px;
  padding-right: 10px;
  & button {
    float: right;
  }
`;

export const CounterChars = styled.div`
  float: right;
  font-size: 11px;
  text-transform: uppercase;
  background: #d0d9db;
  padding: 2px 10px;
  font-weight: 600;
  margin-top: 4px;
  color: #32302e;
  letter-spacing: 1px;
`;

export const ContainerForm = styled.div`
  flex: 1;
  ${clearFix()};
`;

export const Header = styled.div`
  height: 60px;
  border-bottom: 1px solid rgba(151, 151, 151, 0.2);
  & h5 {
    text-align: center !important;
    line-height: 60px !important;
    margin: 0 !important;
  }
`;

export const Row = styled.div<{ big?: boolean }>`
  ${clearFix()};
  border-bottom: 1px solid rgba(151, 151, 151, 0.2);
  height: ${props => (props.big ? '180px' : 'auto')};
  display: flex;
  padding: 20px;
  & textarea {
    height: 120px;
  }
  & label {
    width: 200px;
    line-height: 40px;
    ${media.lessThan('medium')`
    width: 100%;
  `};
  }

  ${media.lessThan('medium')`
    display: block;

  `};
`;

interface Props {
  isOpen: boolean;
  toggleModal: any;
  collectionId: string;
}

const Modal: React.SFC<Props> = ({ isOpen, toggleModal, children }) => {
  return isOpen ? (
    <div>
      <Background onClick={toggleModal} />
      <Dialog>
        <Action>
          <Close onClick={toggleModal}>
            <Cross width={20} height={20} strokeWidth={2} color="#333" />
          </Close>
        </Action>
        <Content>{children}</Content>
      </Dialog>
    </div>
  ) : null;
};

export default Modal;
