import * as React from 'react';

import { Trans } from '@lingui/macro';

import { Grid, Row, Col } from '@zendeskgarden/react-grid';
// import { Redirect } from 'react-router';
// import { Tabs, TabPanel } from '../../components/chrome/Tabs/Tabs';

// import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';

import CommunityCard from '../../components/elements/Community/Community';
import CollectionCard from '../../components/elements/Collection/Collection';
import ResourceCard from '../../components/elements/Resource/Resource';

// import Logo from '../../components/brand/Logo/Logo';
// import P from '../../components/typography/P/P';
// import media from 'styled-media-query';

import algoliasearch from 'algoliasearch/lite';
import {
  InstantSearch,
  Hits,
  SearchBox,
  Pagination,
  // Highlight,
  ClearRefinements,
  RefinementList,
  Configure
} from 'react-instantsearch-dom';

const searchClient = algoliasearch(
  'KVG4RFL0JJ',
  '2b7ba2703d3f4bac126ea5765c2764eb'
);

console.log('search WIP!');

function Hit(props) {
  var community = props.hit;

  return (
    <Row>
      <Col md={4}>
        <CommunityCard
          // key={i}
          summary={community.summary}
          title={community.name}
          icon={community.icon || ''}
          id={''}
          followed={community.followed}
          followersCount={0}
          collectionsCount={community.collections.length}
          externalId={community.id}
          threadsCount={0}
        />
      </Col>
      <Col md={8}>
        {community.collections.map((collection, i_col) => (
          <Row>
            <Col>
              <CollectionCard
                key={i_col}
                collection={collection}
                communityId={''}
              />
            </Col>
            <Col>{collection_resources(collection)}</Col>
          </Row>
        ))}
      </Col>
    </Row>
  );
}

function collection_resources(collection) {
  const urlParams = new URLSearchParams(window.location.search);
  const moodle_core_download_url = decodeURI(
    urlParams.get('moodle_core_download_url') || ''
  );
  return collection.resources.map((resource, i_res) => (
    <ResourceCard
      key={i_res}
      icon={resource.icon}
      title={resource.name}
      summary={resource.summary}
      url={resource.url}
      coreIntegrationURL={
        moodle_core_download_url +
        `&externalurl=` +
        encodeURIComponent(resource.url) +
        `&externalname=` +
        encodeURIComponent(resource.name) +
        `&externaldescription=` +
        encodeURIComponent(resource.summary)
      }
      // localId={resource.localId}
    />
  ));
}

// const List = styled.div`
//   display: grid;
//   grid-template-columns: 1fr 1fr 1fr;
//   grid-column-gap: 16px;
//   grid-row-gap: 16px;
//   // padding: 16px;
//   // background: white;
//   padding-top: 0;
//   ${media.lessThan('medium')`
//   grid-template-columns: 1fr;
//   `};
// `;

export default class extends React.Component {
  // ={'test'}

  render() {
    //TODO support maybe not good enough? e.g. no ie 11 (https://caniuse.com/#feat=urlsearchparams)
    //TODO this is not SSR friendly, accessing window.location!! does react router give query params?

    // const urlParams = new URLSearchParams(window.location.search);
    // // const query = urlParams.get('q');
    // const moodle_core_download_url = urlParams.get('moodle_core_download_url');

    // if (!query) {
    //   return <Redirect to="/" />;
    // }

    return (
      <Main>
        <link
          rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/instantsearch.css@7.1.1/themes/reset-min.css"
        />

        <InstantSearch searchClient={searchClient} indexName="next_moodlenet">
          <SearchBox />
          <h2>
            <Trans>Filter</Trans>
          </h2>
          <RefinementList attribute="isAccessibleForFree" />
          <ClearRefinements />
          <Configure hitsPerPage={8} />
          <Grid>
            <Hits hitComponent={Hit} />
          </Grid>
          <Pagination />
        </InstantSearch>
      </Main>
    );
  }
}
