import * as React from 'react';
import { Col, Row } from '@zendeskgarden/react-grid';

import { Trans } from '@lingui/macro';
import { i18nMark } from '@lingui/react';

const tt = {
  placeholders: {
    search: i18nMark('Search for tags')
  }
};

import H6 from '../../components/typography/H6/H6';
import P from '../../components/typography/P/P';
import TextInput from '../../components/inputs/Text/Text';
import Button from '../../components/elements/Button/Button';
import Tag, { TagContainer } from '../../components/elements/Tag/Tag';
import styled from '../../themes/styled';
import User from '../../types/User';

//TODO get tags from the API
const words = `Applied Sciences, K12, Performing Arts, Humanities, Higher Education, Social Sciences, Vocational Education, Professional Education, Formal Sciences, Natural Sciences, Visual Arts`
  .split(',')
  .map(s => s.trim());

const InterestsSearchResultsContainer = styled.div`
  margin: 20px 0 0 0;
`;

const OverflowCol = styled(Col)`
  overflow: auto;
`;

function InterestsSearchResults({ status, count, result, children }) {
  if (status === SearchStatus.complete) {
    return (
      <InterestsSearchResultsContainer>
        <P style={{ fontWeight: 'bold' }}>
          {count} <Trans>Search Results</Trans>
        </P>
        {children}
      </InterestsSearchResultsContainer>
    );
  }
  if (status === SearchStatus.in_progress) {
    return (
      <InterestsSearchResultsContainer>
        <Trans>Searching...</Trans>
      </InterestsSearchResultsContainer>
    );
  }
  if (status === SearchStatus.error) {
    return (
      <InterestsSearchResultsContainer>
        <Trans>Could not search at this time, please try again later.</Trans> (
        {result.message})
      </InterestsSearchResultsContainer>
    );
  }
  // status === SearchStatus.idle
  return null;
}

enum SearchStatus {
  idle,
  in_progress,
  complete,
  error
}

type Step2Props = {
  user: User;
  toggleInterest: Function;
};

type Step2State = {
  interestsSearch: {
    status: SearchStatus;
    count: number;
    result: any;
  };
};

export default class extends React.Component<Step2Props, Step2State> {
  _searchTimeout: number = -1;

  state = {
    interestsSearch: {
      status: SearchStatus.idle,
      count: -1,
      result: null
    }
  };

  constructor(props) {
    super(props);
    this.onInterestsSearchSubmit = this.onInterestsSearchSubmit.bind(this);
  }

  // TODO search using API
  onInterestsSearchSubmit(e) {
    if (this._searchTimeout) {
      clearTimeout(this._searchTimeout);
    }

    e.preventDefault();

    this.setState({
      interestsSearch: {
        status: SearchStatus.in_progress,
        count: -1,
        result: null
      }
    });

    this._searchTimeout = window.setTimeout(() => {
      this.setState({
        interestsSearch: {
          status: SearchStatus.complete,
          count: words.length,
          result: words
        }
      });
    }, 2000);
  }

  render() {
    const { user, toggleInterest } = this.props;

    return (
      <>
        <Row>
          <OverflowCol>
            <H6 style={{ borderBottom: '1px solid lightgrey' }}>
              <span style={{ color: 'darkgrey', fontSize: '.7em' }}>2.</span>{' '}
              <Trans>Your Interests</Trans>
            </H6>
            <P>
              <Trans>
                Your interests will be displayed on your profile, and will also
                help MoodleNet recommend content that is relevant to you.
              </Trans>
            </P>
            <form onSubmit={this.onInterestsSearchSubmit}>
              <TextInput
                placeholder={tt.placeholders.search}
                button={
                  <Button type="submit">
                    <Trans>Search</Trans>
                  </Button>
                }
              />
            </form>
            <InterestsSearchResults {...this.state.interestsSearch}>
              <TagContainer>
                {words.map(word => (
                  <Tag
                    focused={user.interests.includes(word)}
                    key={word}
                    onClick={() => toggleInterest(word)}
                  >
                    {word}
                  </Tag>
                ))}
              </TagContainer>
            </InterestsSearchResults>
            <P style={{ fontWeight: 'bold' }}>
              <Trans>Popular on MoodleNet</Trans>
            </P>
            <P>
              <Trans>Here are some trending tags you could add</Trans>.
            </P>
            <TagContainer>
              {words.map(word => (
                <Tag
                  focused={user.interests.includes(word)}
                  key={word}
                  onClick={() => toggleInterest(word)}
                >
                  {word}
                </Tag>
              ))}
            </TagContainer>
          </OverflowCol>
        </Row>
      </>
    );
  }
}
