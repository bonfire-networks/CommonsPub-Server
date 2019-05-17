// View a Collection (with list of resources)

import * as React from 'react';

import { Trans } from '@lingui/macro';
import { clearFix } from 'polished';
import { Grid } from '@zendeskgarden/react-grid';
import P from '../../components/typography/P/P';
import styled from '../../themes/styled';
import Main from '../../components/chrome/Main/Main';
import { graphql, GraphqlQueryControls, OperationOption } from 'react-apollo';
import Collection from '../../types/Collection';
import { compose, withState, withHandlers } from 'recompose';
import { RouteComponentProps } from 'react-router';
import Loader from '../../components/elements/Loader/Loader';
import Breadcrumb from './breadcrumb';
import CollectionModal from '../../components/elements/CollectionModal';
import EditCollectionModal from '../../components/elements/EditCollectionModal';
const getCollection = require('../../graphql/getCollection.graphql');
import H2 from '../../components/typography/H2/H2';
import { Route, Switch } from 'react-router-dom';
import Thread from '../thread';
import CollectionPage from './collection';
import Join from '../../components/elements/Collection/Join';
import { Settings } from '../../components/elements/Icons';

import media from 'styled-media-query';

enum TabsEnum {
  // Members = 'Members',
  Resources = 'Resources',
  Discussion = 'Discussion'
}

interface Data extends GraphqlQueryControls {
  collection: Collection;
}

interface Props
  extends RouteComponentProps<{
      community: string;
      collection: string;
    }> {
  data: Data;
  addNewResource(): boolean;
  isOpen: boolean;
  editCollection(): boolean;
  isEditCollectionOpen: boolean;
}

class CollectionComponent extends React.Component<Props> {
  state = {
    tab: TabsEnum.Resources
  };

  render() {
    let collection;
    let resources;
    if (this.props.data.error) {
      collection = null;
    } else if (this.props.data.loading) {
      return <Loader />;
    } else {
      collection = this.props.data.collection;
      resources = this.props.data.collection
        ? this.props.data.collection.resources
        : [];
    }
    if (!collection) {
      // TODO better handling of no collection
      return (
        <span>
          <Trans>Could not load the collection.</Trans>
        </span>
      );
    }

    let community_name = collection.community.name;

    return (
      <>
        <Main>
          <Grid>
            <WrapperCont>
              <HeroCont>
                <Breadcrumb
                  community={{
                    id: collection.community.localId,
                    name: collection.community.name
                  }}
                  collectionName={collection.name}
                />
                <Hero>
                  <Background
                    style={{ backgroundImage: `url(${collection.icon})` }}
                  />
                  <HeroInfo>
                    <H2>{collection.name}</H2>
                    <P>
                      {collection.summary.split('\n').map(function(item, key) {
                        return (
                          <span key={key}>
                            {item}
                            <br />
                          </span>
                        );
                      })}
                    </P>
                    <ActionsHero>
                      <HeroJoin>
                        <Join
                          followed={collection.followed}
                          id={collection.localId}
                          externalId={collection.id}
                        />
                      </HeroJoin>
                      {collection.community.followed ? (
                        <EditButton onClick={this.props.editCollection}>
                          <Settings
                            width={18}
                            height={18}
                            strokeWidth={2}
                            color={'#f98012'}
                          />
                          <Trans>Edit collection</Trans>
                        </EditButton>
                      ) : null}
                    </ActionsHero>
                  </HeroInfo>
                </Hero>
                <Actions />
              </HeroCont>
              <Switch>
                <Route
                  path={`/collections/${collection.localId}/thread/:id`}
                  component={Thread}
                />
                <Route
                  path={this.props.match.url}
                  exact
                  render={props => (
                    <CollectionPage
                      {...props}
                      collection={collection}
                      community_name={community_name}
                      resources={resources}
                      addNewResource={this.props.addNewResource}
                      fetchMore={this.props.data.fetchMore}
                      type={'collection'}
                    />
                  )}
                />
              </Switch>
            </WrapperCont>
          </Grid>
          <CollectionModal
            toggleModal={this.props.addNewResource}
            modalIsOpen={this.props.isOpen}
            collectionId={collection.localId}
            collectionExternalId={collection.id}
          />
          <EditCollectionModal
            toggleModal={this.props.editCollection}
            modalIsOpen={this.props.isEditCollectionOpen}
            collectionId={collection.localId}
            collectionExternalId={collection.id}
            collection={collection}
          />
        </Main>
      </>
    );
  }
}

const ActionsHero = styled.div`
  margin-top: 8px;
  ${clearFix()};
  & div {
    &:hover {
      background: transparent;
    }
  }
`;
const HeroJoin = styled.div`
  width: 38px;
  position: absolute;
  top: 0px;
  right: 0px;
  text-align: center;
`;

const Actions = styled.div``;

const WrapperCont = styled.div`
  max-width: 1040px;
  margin: 0 auto;
  width: 100%;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
`;

const EditButton = styled.span`
  color: ${props => props.theme.styles.colour.heroCollectionIcon};
  height: 40px;
  font-weight: 600;
  font-size: 13px;
  line-height: 38px;
  margin-left: 24px;
  cursor: pointer;
  display: inline-block;
  & svg {
    margin-top: 8px;
    text-align: center;
    vertical-align: text-bottom;
    margin-right: 8px;
    color: inherit !important;
  }
`;

const HeroInfo = styled.div`
  flex: 1;
  margin-left: 16px;
  position: relative;
  ${clearFix()};
  & h2 {
    margin: 0;
    line-height: 32px !important;
    font-size: 24px !important;
    color: ${props => props.theme.styles.colour.heroCollectionTitle};
    ${media.lessThan('medium')`
      margin-top: 8px;
    `};
  }
  & p {
    margin: 0;
    color: rgba(0, 0, 0, 0.8);
    font-size: 15px;
    margin-top: 8px;
    color: ${props => props.theme.styles.colour.heroCollectionNote};
  }
`;
const HeroCont = styled.div`
  margin-bottom: 16px;
  border-radius: 6px;
  box-sizing: border-box;
  background: ${props => props.theme.styles.colour.heroCollection};
`;

const Hero = styled.div`
  display: flex;
  width: 100%;
  position: relative;
  padding: 16px;
  ${media.lessThan('medium')`
  text-align: center;
  display: block;
`};
`;

const Background = styled.div`
  height: 120px;
  width: 120px;
  border-radius: 4px;
  background-size: cover;
  background-repeat: no-repeat;
  background-color: ${props => props.theme.styles.colour.base4};
  position: relative;
  margin: 0 auto;
`;

const withGetCollection = graphql<
  {},
  {
    data: {
      collection: Collection;
    };
  }
>(getCollection, {
  options: (props: Props) => ({
    variables: {
      limit: 15,
      id: Number(props.match.params.collection)
    }
  })
}) as OperationOption<{}, {}>;

export default compose(
  withGetCollection,
  withState('isOpen', 'onOpen', false),
  withState('isEditCollectionOpen', 'onEditCollectionOpen', false),
  withHandlers({
    addNewResource: props => () => props.onOpen(!props.isOpen),
    editCollection: props => () =>
      props.onEditCollectionOpen(!props.isEditCollectionOpen)
  })
)(CollectionComponent);
