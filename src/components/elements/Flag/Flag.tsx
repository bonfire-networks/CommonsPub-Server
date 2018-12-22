import * as React from 'react';

/**
 * Display a country flag icon using the `flag-icon-css` library.
 * @param flag {String} class name of the flag to display
 */
export default function({ flag }) {
  return <div className={`flag-icon flag-icon-${flag}`} />;
}
