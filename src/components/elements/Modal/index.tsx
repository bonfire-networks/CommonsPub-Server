import * as React from 'react';
import ReactDOM from 'react-dom';
import Modal from './modal';
const modalRoot = document.getElementById('modal') as HTMLElement;

interface PortalState {
  el: any;
}

class Portal extends React.Component<{}, PortalState> {
  el: HTMLElement = document.createElement('div');

  componentDidMount() {
    modalRoot.appendChild(this.el);
  }

  componentWillUnmount() {
    modalRoot.removeChild(this.el);
  }

  render() {
    return ReactDOM.createPortal(this.props.children, this.el);
  }
}

export default props => (
  <Portal>
    <Modal {...props} />
  </Portal>
);
