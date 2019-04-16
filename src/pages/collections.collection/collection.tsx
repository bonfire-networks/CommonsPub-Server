import * as React from 'react';
import { SFC } from 'react';
import { Trans } from '@lingui/macro';
import { Tabs, TabPanel } from 'react-tabs';
import Discussion from '../../components/chrome/Discussion/Discussion';
import TimelineItem from '../../components/elements/TimelineItem';
import styled from '../../themes/styled';
import { SuperTab, SuperTabList } from '../../components/elements/SuperTab';
import ResourceCard from '../../components/elements/Resource/Resource';
import P from '../../components/typography/P/P';
import { Actions, Create } from '../communities.community/CommunitiesCommunity';
// import { clearFix } from 'polished';
import { Resource, Message, Eye } from '../../components/elements/Icons';
import Link from '../../components/elements/Link/Link';
import {
  Footer,
  WrapperTab,
  OverlayTab
} from '../communities.community/Community';
// import CollectionsLoadMore from 'src/components/elements/Loadmore/followingCollections';

interface Props {
  collection: any;
  community_name: string;
  resources: any;
  fetchMore: any;
  type: string;
  match: any;
  addNewResource: any;
}

const CommunityPage: SFC<Props> = ({
  collection,
  community_name,
  resources,
  fetchMore,
  addNewResource,
  type
}) => (
  <WrapperTab>
    <OverlayTab>
      <Tabs>
        <SuperTabList>
          <SuperTab>
            <span>
              <Eye width={20} height={20} strokeWidth={2} color={'#a0a2a5'} />
            </span>
            <h5>
              <Trans>Timeline</Trans>
            </h5>
          </SuperTab>
          <SuperTab>
            <span>
              <Resource
                width={20}
                height={20}
                strokeWidth={2}
                color={'#a0a2a5'}
              />
            </span>
            <h5>
              <Trans>Resources</Trans> ({collection.resources.totalCount}
              /10)
            </h5>
          </SuperTab>
          <SuperTab>
            <span>
              <Message
                width={20}
                height={20}
                strokeWidth={2}
                color={'#a0a2a5'}
              />
            </span>{' '}
            <h5>
              <Trans>Discussions</Trans>
            </h5>
          </SuperTab>
        </SuperTabList>
        <TabPanel>
          <div>
            {collection.inbox.edges.map((t, i) => (
              <TimelineItem node={t.node} user={t.node.user} key={i} />
            ))}
            {/* <CollectionsLoadMore 
              fetchMore={fetchMore}
              inbox={}
            /> */}
            {(collection.inbox.pageInfo.startCursor === null &&
              collection.inbox.pageInfo.endCursor === null) ||
            (collection.inbox.pageInfo.startCursor &&
              collection.inbox.pageInfo.endCursor === null) ? null : (
              <LoadMore
                onClick={() =>
                  fetchMore({
                    variables: {
                      end: collection.inbox.pageInfo.endCursor
                    },
                    updateQuery: (previousResult, { fetchMoreResult }) => {
                      const newNodes = fetchMoreResult.collection.inbox.edges;
                      const pageInfo =
                        fetchMoreResult.collection.inbox.pageInfo;
                      return newNodes.length
                        ? {
                            // Put the new comments at the end of the list and update `pageInfo`
                            // so we have the new `endCursor` and `hasNextPage` values
                            collection: {
                              ...previousResult.collection,
                              __typename: previousResult.collection.__typename,
                              inbox: {
                                ...previousResult.collection.inbox,
                                edges: [
                                  ...previousResult.collection.inbox.edges,
                                  ...newNodes
                                ]
                              },
                              pageInfo
                            }
                          }
                        : {
                            collection: {
                              ...previousResult.collection,
                              __typename: previousResult.collection.__typename,
                              inbox: {
                                ...previousResult.collection.inbox,
                                edges: [
                                  ...previousResult.collection.inbox.edges
                                ]
                              },
                              pageInfo
                            }
                          };
                    }
                  })
                }
              >
                <Trans>Load more</Trans>
              </LoadMore>
            )}
          </div>
        </TabPanel>
        <TabPanel>
          <div
            style={{
              display: 'flex',
              flexWrap: 'wrap'
            }}
          >
            <Wrapper>
              {resources.totalCount > 9 ? null : collection.community
                .followed ? (
                <Actions>
                  <Create onClick={addNewResource}>
                    <span>
                      <Resource
                        width={18}
                        height={18}
                        strokeWidth={2}
                        color={'#f0f0f0'}
                      />
                    </span>
                    <Trans>Add a new resource</Trans>
                  </Create>
                </Actions>
              ) : (
                <Footer>
                  <Trans>Join the community</Trans>{' '}
                  <Link to={'/communities/' + collection.community.localId}>
                    {community_name}
                  </Link>{' '}
                  <Trans>to add a resource</Trans>
                </Footer>
              )}
              {resources.totalCount ? (
                <CollectionList>
                  {resources.edges.map((edge, i) => (
                    <ResourceCard
                      key={i}
                      icon={edge.node.icon}
                      title={edge.node.name}
                      summary={edge.node.summary}
                      url={edge.node.url}
                      localId={edge.node.localId}
                    />
                  ))}
                </CollectionList>
              ) : (
                <OverviewCollection>
                  <P>
                    <Trans>This collection has no resources.</Trans>
                  </P>
                </OverviewCollection>
              )}
            </Wrapper>
          </div>
        </TabPanel>
        <TabPanel>
          {collection.community.followed ? (
            <Discussion
              localId={collection.localId}
              id={collection.id}
              threads={collection.threads}
              followed
            />
          ) : (
            <>
              <Discussion
                localId={collection.localId}
                id={collection.id}
                threads={collection.threads}
                type={type}
              />
              <Footer>
                <Trans>Join the community</Trans>{' '}
                <Link to={'/communities/' + collection.community.localId}>
                  {community_name}
                </Link>{' '}
                <Trans>to participate in discussions</Trans>
              </Footer>
            </>
          )}
        </TabPanel>
      </Tabs>
    </OverlayTab>
  </WrapperTab>
);

// const Actions = styled.div`
//   ${clearFix()};
//   display: flex;
//   border-bottom: 1px solid #edf0f2;
//   & button {
//     border-radius: 4px;
//     background: #f98012;
//     font-size: 13px;
//     font-weight: 600;
//     line-height: 35px;
//     text-align: center;
//     cursor: pointer;
//     color: #f0f0f0;
//     margin: 8px;
//     float: left;
//     padding: 0 16px;
//     display: inline-block;
//   }
//   span {
//     & svg {
//       vertical-align: middle;
//       margin-right: 16px;
//     }
//   }
// `;

const Wrapper = styled.div`
  flex: 1;
`;

const CollectionList = styled.div`
  flex: 1;
`;

const OverviewCollection = styled.div`
  padding: 8px;
  & p {
    margin-top: 14px !important;
    font-size: 14px;
  }
`;

const LoadMore = styled.div`
  text-align: center;
  vertical-align: middle;
  cursor: pointer;
  white-space: nowrap;
  line-height: 20px;
  padding: 8px 13px;
  border-radius: 4px;
  user-select: none;
  color: #667d99;
  background: #e7edf3;
  background-color: rgb(231, 237, 243);
  background-color: rgb(231, 237, 243);
  border: 0;
  font-size: 13px;
  margin: 8px;
  &:hover {
    background: #e7e7e7;
  }
`;

export default CommunityPage;
