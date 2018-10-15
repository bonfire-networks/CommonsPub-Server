import * as React from 'react';
import { Col, Row } from '@zendeskgarden/react-grid';
import { Tag as ZenTag } from '@zendeskgarden/react-tags';

import H6 from '../../components/typography/H6/H6';
import P from '../../components/typography/P/P';
import Button from '../../components/elements/Button/Button';
import styled from '../../themes/styled';
import Tag from '../../components/elements/Tag/Tag';

const Spacer = styled.div`
  width: 10px;
  height: 10px;
`;

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

const TagContainer = styled.div`
  ${ZenTag} {
    margin: 0 5px 5px 0;
  }
`;

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
              <Tag key={word}>{word}</Tag>
            ))}
          </TagContainer>
          <P style={{ fontWeight: 'bold' }}>Popular on MoodleNet</P>
          <P>These tags are popular on MoodleNet.</P>
          <TagContainer>
            {words1.map(word => (
              <Tag
                key={word}
                type={user.interests.includes(word) ? 'green' : undefined}
                onClick={() => toggleInterest(word)}
              >
                {word}
              </Tag>
            ))}
          </TagContainer>
        </Col>
      </Row>
      <Row style={{ flexGrow: 1 }} />
      <Row>
        <Col style={{ display: 'flex', alignItems: 'center', color: 'grey' }}>
          Next: discover
        </Col>
        <Col style={{ display: 'flex', justifyContent: 'flex-end' }}>
          <Button secondary onClick={goToNextStep}>
            Skip
          </Button>
          <Spacer />
          <Button onClick={goToNextStep}>Continue</Button>
        </Col>
      </Row>
    </>
  );
};
