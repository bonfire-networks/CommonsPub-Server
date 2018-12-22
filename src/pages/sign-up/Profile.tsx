import * as React from 'react';

import styled from '../../themes/styled';
import H4 from '../../components/typography/H4/H4';
import Tag, { TagContainer } from '../../components/elements/Tag/Tag';
import Button from '../../components/elements/Button/Button';

const Step2Section = styled.div<any>`
  opacity: ${props => (props.active ? 1 : 0.1)};
  pointer-events: ${props => (props.active ? 'unset' : 'none')};
  transition: opacity 1.75s linear;
`;

const TagsNoneSelected = ({ what }) => {
  return (
    <div style={{ paddingTop: '8px', color: 'grey' }}>No {what} selected</div>
  );
};

export const SignUpProfileSection = styled.div<any>`
  padding: 50px;
`;

export const Interests = ({ active, interests, onTagClick }) => (
  <Step2Section active={active}>
    <H4>Interests</H4>
    <TagContainer>
      {interests.length ? (
        interests.map(interest => (
          <Tag
            focused
            closeable
            key={interest}
            onClick={() => onTagClick(interest)}
          >
            {interest}
          </Tag>
        ))
      ) : (
        <TagsNoneSelected what="interests" />
      )}
    </TagContainer>
    <Button onClick={() => alert('add interest clicked')}>Add interest</Button>
  </Step2Section>
);

export const Languages = ({ active, languages }) => (
  <Step2Section active={active}>
    <H4>Languages</H4>
    <TagContainer>
      {languages.length ? (
        languages.map(lang => (
          <Tag
            focused
            closeable
            key={lang}
            onClick={() => alert('lang clicked')}
          >
            {lang}
          </Tag>
        ))
      ) : (
        <TagsNoneSelected what="languages" />
      )}
    </TagContainer>
    <Button onClick={() => alert('add lang clicked')}>Add language</Button>
  </Step2Section>
);
