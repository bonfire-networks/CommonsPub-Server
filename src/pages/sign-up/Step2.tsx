import * as React from 'react';
import { Col, Row } from '@zendeskgarden/react-grid';

import H6 from '../../components/typography/H6/H6';
import P from '../../components/typography/P/P';
import TextInput from '../../components/inputs/Text/Text';
import Button from '../../components/elements/Button/Button';
import Tag, { TagContainer } from '../../components/elements/Tag/Tag';
import styled from '../../themes/styled';
import User from '../../types/User';

//TODO get tags from the API
const words = `offer,segment,slave,duck,instant,market,degree,populate,chick,dear,enemy,reply,drink,occur,support,shell,neck`.split(
  ','
);

const InterestsSearchResultsContainer = styled.div`
  margin: 20px 0 0 0;
`;

function InterestsSearchResults({ status, count, result, children }) {
  if (status === SearchStatus.complete) {
    return (
      <InterestsSearchResultsContainer>
        <P style={{ fontWeight: 'bold' }}>{count} Search Results</P>
        {children}
      </InterestsSearchResultsContainer>
    );
  }
  if (status === SearchStatus.in_progress) {
    return (
      <InterestsSearchResultsContainer>
        Searching...
      </InterestsSearchResultsContainer>
    );
  }
  if (status === SearchStatus.error) {
    return (
      <InterestsSearchResultsContainer>
        Could not search at this time, please try again later. ({result.message}
        )
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
          <Col>
            <H6 style={{ borderBottom: '1px solid lightgrey' }}>
              <span style={{ color: 'darkgrey', fontSize: '.7em' }}>2.</span>{' '}
              Your Interests
            </H6>
            <P>
              Tell us what you're interested in so we can make your MoodleNet
              experience tailored to you.
            </P>
            <form onSubmit={this.onInterestsSearchSubmit}>
              <TextInput
                placeholder="Search for tags"
                button={<Button type="submit">Search</Button>}
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
            <P style={{ fontWeight: 'bold' }}>Popular on MoodleNet</P>
            <P>These tags are popular on MoodleNet.</P>
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
          </Col>
        </Row>
      </>
    );
  }
}
