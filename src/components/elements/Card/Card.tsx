import * as React from 'react';

const { H4 } = require('../../typography/H4/H4');
const { MoodleButton } = require('../Button/Button');

export const Card = ({ title }) => (
  <div className="Card">
    <H4>{title}</H4>
    <MoodleButton>View</MoodleButton>
  </div>
);
