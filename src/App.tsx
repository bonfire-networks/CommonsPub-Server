import * as React from 'react';
const {
  Chrome,
  Nav,
  NavItem,
  NavItemText,
  Header,
  Body,
  HeaderItem,
  HeaderItemWrapper,
  HeaderItemIcon,
  HeaderItemText,
} = require('@zendeskgarden/react-chrome')


const logo = require('./logo.svg');
import './App.css';
import '@zendeskgarden/react-chrome/dist/styles.css'

class App extends React.Component {
  state: any = {
    menuOpen: true
  }

  toggleMenu () {
    this.setState({
      menuOpen: !this.state.menuOpen
    })
  }

  render() {
    return (
      <Chrome className="App">
        <Nav expanded={this.state.menuOpen}>
          <NavItem logo title="MoodleNet" onClick={() => this.toggleMenu()}>
            <NavItemText>MoodleNet</NavItemText>
          </NavItem>
          <NavItem title="Home">
            <NavItemText>Home</NavItemText>
          </NavItem>
        </Nav>
        <Body>
          <Header>
            <HeaderItem product="support">
              <HeaderItemIcon>
                <img src={logo} className="App-logo" alt="logo" />
              </HeaderItemIcon>
              <HeaderItemText>MoodleNet</HeaderItemText>
            </HeaderItem>
            <HeaderItemWrapper maxX>
              <span />
            </HeaderItemWrapper>
          </Header>
          <header className="App-header">
            <h1 className="App-title">Welcome to MoodleNet</h1>
          </header>
          <p className="App-intro">
            body content
          </p>
        </Body>
      </Chrome>
    );
  }
}

export default App;
