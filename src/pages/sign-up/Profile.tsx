import * as React from 'react';

import { Trans } from '@lingui/macro';

import styled from '../../themes/styled';
import H4 from '../../components/typography/H4/H4';
import Tag, { TagContainer } from '../../components/elements/Tag/Tag';
import Button from '../../components/elements/Button/Button';

const Step2Section = styled.div<any>`
  opacity: ${props => (props.active ? 1 : 0.1)};
  pointer-events: ${props => (props.active ? 'unset' : 'none')};
  transition: opacity 1.75s linear;
`;

const TagsNoneSelected = ({ something }) => {
  return (
    <div style={{ paddingTop: '8px', color: 'grey' }}>
      <Trans>No {something} selected</Trans>
    </div>
  );
};

export const SignUpProfileSection = styled.div<any>`
  padding: 50px;
`;

export const Interests = ({ active, interests, onTagClick }) => (
  <Step2Section active={active}>
    <H4>
      <Trans>Interests</Trans>
    </H4>
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
        <TagsNoneSelected something="interests" />
      )}
    </TagContainer>
    <Button onClick={() => alert('add interest clicked')}>
      <Trans>Add interest</Trans>
    </Button>
  </Step2Section>
);

export const Languages = ({ active, languages }) => (
  <Step2Section active={active}>
    <H4>
      <Trans>Languages</Trans>
    </H4>
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
        <TagsNoneSelected something="languages" />
      )}
    </TagContainer>
    <Button onClick={() => alert('add lang clicked')}>
      <Trans>Add language</Trans>
    </Button>
  </Step2Section>
);
