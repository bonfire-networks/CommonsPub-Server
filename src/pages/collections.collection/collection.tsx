import * as React from 'react';
import { SFC } from 'react';
import { clearFix } from 'polished';
import { Trans } from '@lingui/macro';
import { Tabs, TabPanel } from 'react-tabs';
import Discussion from '../../components/chrome/Discussion/Discussion';
import Link from '../../components/elements/Link/Link';
import moment from 'moment';
import styled from '../../themes/styled';
import { SuperTab, SuperTabList } from '../../components/elements/SuperTab';
import ResourceCard from '../../components/elements/Resource/Resource';
import P from '../../components/typography/P/P';
import Button from '../../components/elements/Button/Button';
import media from 'styled-media-query';

import { Resource, Message, Eye } from '../../components/elements/Icons';

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
  match,
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
              <FeedItem key={i}>
                <Member>
                  <MemberItem>
                    <Img alt="user" src={t.node.user.icon} />
                  </MemberItem>
                  <MemberInfo>
                    <h3>
                      <Link to={'/user/' + t.node.user.localId}>
                        {t.node.user.name}
                      </Link>
                      {t.node.activityType === 'CreateCollection' ? (
                        <span>
                          created the collection{' '}
                          <Link
                            to={
                              `/communities/${
                                collection.localId
                              }/collections/` + t.node.object.localId
                            }
                          >
                            {t.node.object.name}
                          </Link>{' '}
                        </span>
                      ) : t.node.activityType === 'UpdateCommunity' ? (
                        <span>updated the community</span>
                      ) : t.node.activityType === 'UpdateCollection' ? (
                        <span>
                          updated the collection{' '}
                          <Link to={`/collections/` + t.node.object.localId}>
                            {t.node.object.name}
                          </Link>
                        </span>
                      ) : t.node.activityType === 'JoinCommunity' ? (
                        <span>joined the community</span>
                      ) : t.node.activityType === 'CreateComment' ? (
                        <span>
                          posted a new{' '}
                          <Link
                            to={
                              `/collections/${collection.localId}/thread/` +
                              t.node.object.localId
                            }
                          >
                            comment
                          </Link>{' '}
                        </span>
                      ) : t.node.activityType === 'CreateResource' ? (
                        <span>
                          created the resource <b>{t.node.object.name}</b>
                        </span>
                      ) : t.node.activityType === 'FollowCollection' ? (
                        <span>
                          started to follow the collection{' '}
                          <b>{t.node.object.name}</b>
                        </span>
                      ) : null}
                    </h3>
                    <Date>{moment(t.node.published).fromNow()}</Date>
                  </MemberInfo>
                </Member>
              </FeedItem>
            ))}
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
              flexWrap: 'wrap',
              background: '#e9ebef'
            }}
          >
            <Wrapper>
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

              {resources.totalCount > 9 ? null : collection.community
                .followed ? (
                <WrapperActions>
                  <Button onClick={addNewResource}>
                    <Trans>Add a new resource</Trans>
                  </Button>
                </WrapperActions>
              ) : (
                <Footer>
                  <Trans>
                    Join the <strong>{community_name}</strong> community to add
                    a resource
                  </Trans>
                </Footer>
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
                <Trans>
                  Join the <strong>{community_name}</strong> community to
                  participate in discussions
                </Trans>
              </Footer>
            </>
          )}
        </TabPanel>
      </Tabs>
    </OverlayTab>
  </WrapperTab>
);

const Wrapper = styled.div`
  flex: 1;
`;

const CollectionList = styled.div`
  flex: 1;
  margin: 10px;
`;

const OverviewCollection = styled.div`
  padding: 8px;
  & p {
    margin-top: 14px !important;
    font-size: 14px;
  }
`;

const Footer = styled.div`
  height: 30px;
  line-height: 30px;
  font-weight: 600;
  text-align: center;
  background: #ffefd9;
  font-size: 13px;
  border-bottom: 1px solid #e4dcc3;
  color: #544f46;
`;

const WrapperTab = styled.div`
  display: flex;
  flex: 1;
  height: 100%;
  border-radius: 6px;
  height: 100%;
  box-sizing: border-box;
  border: 5px solid #e2e5ea;
  margin-bottom: 24px;
`;
const OverlayTab = styled.div`
  background: #fff;
  height: 100%;
  width: 100%;

  & > div {
    flex: 1;
    height: 100%;
  }
`;

const WrapperActions = styled.div`
  margin: 8px;
  & button {
    ${media.lessThan('medium')`
   width: 100%;
    `};
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

const Member = styled.div`
  vertical-align: top;
  margin-right: 14px;
  ${clearFix()};
`;

const MemberInfo = styled.div`
  display: inline-block;
  & h3 {
    font-size: 14px;
    margin: 0;
    color: ${props => props.theme.styles.colour.base2};
    font-weight: 400;
    & span {
      margin: 0 4px;
    }
    & a {
      text-decoration: none;
      font-weight: 500;
    }
  }
`;

const MemberItem = styled.span`
  background-color: #d6dadc;
  border-radius: 50px;
  color: #4d4d4d;
  display: inline-block;
  height: 32px;
  overflow: hidden;
  position: relative;
  width: 32px;
  user-select: none;
  z-index: 0;
  vertical-align: inherit;
  margin-right: 8px;
`;

const Img = styled.img`
  width: 32px;
  height: 32px;
  display: block;
  -webkit-appearance: none;
  line-height: 32px;
  text-indent: 4px;
  font-size: 13px;
  overflow: hidden;
  max-width: 32px;
  max-height: 32px;
  text-overflow: ellipsis;
  vertical-align: text-top;
  margin-right: 8px;
`;

const Date = styled.div`
  font-size: 12px;
  line-height: 32px;
  height: 20px;
  margin: 0;
  color: #667d99;
  margin-top: 0px;
  font-weight: 500;
`;

const FeedItem = styled.div`
min-height: 30px;
position: relative;
margin: 0;
padding: 16px;
word-wrap: break-word;
font-size: 14px;
${clearFix()};
transition: background 0.5s ease;
background: #fff;
margin-top: 0
z-index: 10;
position: relative;
border-bottom: 1px solid #eaeaea;
`;

export default CommunityPage;
