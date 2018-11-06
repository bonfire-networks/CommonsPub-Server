import * as React from 'react';
import { Col, Row } from '@zendeskgarden/react-grid';

import H6 from '../../components/typography/H6/H6';
import P from '../../components/typography/P/P';
import Tag, { TagContainer } from '../../components/elements/Tag/Tag';

//TODO get tags from the API
const words = `offer
segment
slave
duck
instant
market
degree
populate
chick
dear
enemy
reply
drink
occur
support
shell
neck`;

// https://stackoverflow.com/a/6274381/2039244
function shuffle(a) {
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

const words1 = shuffle(words.split('\n'));
const words2 = shuffle(words.split('\n'));

export default ({ user, goToNextStep, toggleInterest }) => {
  return (
    <>
      <Row>
        <Col>
          <H6 style={{ borderBottom: '1px solid lightgrey' }}>
            <span style={{ color: 'darkgrey', fontSize: '.7em' }}>2.</span> Your
            Interests
          </H6>
          <P>
            Tell us what you're interested in so we can make your MoodleNet
            experience tailored to you.
          </P>
          <TagContainer>
            {words2.map(word => (
              <Tag
                closeable={user.interests.includes(word)}
                focused={user.interests.includes(word)}
                key={word}
                onClick={() => toggleInterest(word)}
              >
                {word}
              </Tag>
            ))}
          </TagContainer>
          <P style={{ fontWeight: 'bold' }}>Popular on MoodleNet</P>
          <P>These tags are popular on MoodleNet.</P>
          <TagContainer>
            {words1.map(word => (
              <Tag
                focused={user.interests.includes(word)}
                key={word}
                onClick={() => toggleInterest(word)}
              >
                {word}
              </Tag>
            ))}
          </TagContainer>
        </Col>
      </Row>
    </>
  );
};
