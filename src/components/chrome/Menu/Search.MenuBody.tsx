import * as React from 'react';

import styled, { withTheme } from '../../../themes/styled';

import { Trans } from '@lingui/macro';
import { i18nMark } from '@lingui/react';

const tt = {
  placeholders: {
    search: i18nMark('e.g. russian revolution 1917')
  }
};

import Text from '../../inputs/Text/Text';
import H6 from '../../typography/H6/H6';
import Button from '../../elements/Button/Button';
import Tag from '../../elements/Tag/Tag';
import Link from '../../elements/Link/Link';
import { withRouter } from 'react-router';

const SearchHeading = styled(H6)`
  margin-block-start: 0.5em;
  margin-block-end: 0.5em;
`;

const StyledTag = styled(Tag)`
  margin: 0 5px 5px 0;
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

const links = ['The Russian Revolution', 'Joseph Stalin', 'Lenin'];

/**
 * The Search page of the Menu. It allows the user to start a search
 * for a term across collections and communities and more or to
 * see popular search phrases and search using them.
 */
export default withRouter(withTheme(({ closeMenu, history, theme }: any) => {
  return (
    <div>
      <SearchHeading>
        <Trans>Search</Trans>{' '}
        <span style={{ color: theme.styles.colour.primary }}>MoodleNet</span>
      </SearchHeading>
      <form
        action="/search"
        onSubmit={e => {
          e.preventDefault();
          const el: HTMLInputElement = document.getElementById(
            'searchInput'
          ) as HTMLInputElement;
          history.push('/search?q=' + el.value);
          closeMenu();
        }}
      >
        <Text
          name="q"
          id="searchInput"
          placeholder={tt.placeholders.search}
          button={
            <Button type="submit">
              <Trans>Search</Trans>
            </Button>
          }
        />
      </form>
      <SearchHeading>
        <Trans>Popular tags</Trans>
      </SearchHeading>
      <div>
        {words.split('\n').map(word => (
          <StyledTag key={word} onClick={() => alert(word)}>
            {word}
          </StyledTag>
        ))}
      </div>
      <SearchHeading>
        <Trans>Popular search phrases</Trans>
      </SearchHeading>
      <div>
        {links.map(link => (
          <>
            <Link to={`/search?q=${encodeURIComponent(link)}`}>{link}</Link>
            <br />
          </>
        ))}
      </div>
    </div>
  );
}) as any);
