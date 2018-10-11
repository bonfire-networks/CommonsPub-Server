import * as React from 'react';

import Nav from '../../components/chrome/Nav/Nav';
import Menu from '../../components/chrome/Menu/Menu';
import Body from '../../components/chrome/Body/Body';
import { RouteComponentProps } from 'react-router';

export default function Home(props: RouteComponentProps) {
  return (
    <>
      <Nav />
      <Body>HOME</Body>
      <Menu />
    </>
  );
}
