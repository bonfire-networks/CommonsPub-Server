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

import { Collection, Message, Eye } from '../../components/elements/Icons';

interface Props {
  collections: any;
  community: any;
  fetchMore: any;
  match: any;
}

const CommunityPage: SFC<Props> = ({
  collections,
  community,
  fetchMore,
  match
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
              <Collection
                width={20}
                height={20}
                strokeWidth={2}
                color={'#a0a2a5'}
              />
            </span>
            <h5>
              <Trans>Collections</Trans>
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
            {community.inbox.edges.map((t, i) => (
              <FeedItem key={i}>
                <Member>
                  <MemberItem>
                    <Img alt="user" src={t.node.user.icon} />
                  </MemberItem>
                  <MemberInfo>
                    <h3>
                      <Link to={'/user/' + t.node.user.localId}>
                        <Name>{t.node.user.name}</Name>
                      </Link>
                      {t.node.activityType === 'CreateCollection' ? (
                        <span>
                          created the collection{' '}
                          <Link
                            to={
                              `/communities/${community.localId}/collections/` +
                              t.node.object.localId
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
                          <Link
                            to={
                              `/communities/${community.localId}/collections/` +
                              t.node.object.localId
                            }
                          >
                            {t.node.object.name}
                          </Link>
                        </span>
                      ) : t.node.activityType === 'JoinCommunity' ? (
                        <span>joined the community</span>
                      ) : t.node.activityType === 'CreateComment' ? (
                        <span>posted a new comment </span>
                      ) : t.node.activityType === 'CreateResource' ? (
                        <span>
                          created the resource <b>{t.node.object.name}</b> on
                          collection{' '}
                          <Link
                            to={
                              `/communities/${community.localId}/collections/` +
                              t.node.object.collection.localId
                            }
                          >
                            {t.node.object.collection.name}
                          </Link>{' '}
                        </span>
                      ) : null}
                    </h3>
                    <Date>{moment(t.node.published).fromNow()}</Date>
                  </MemberInfo>
                </Member>
              </FeedItem>
            ))}
            {(community.inbox.pageInfo.startCursor === null &&
              community.inbox.pageInfo.endCursor === null) ||
            (community.inbox.pageInfo.startCursor &&
              community.inbox.pageInfo.endCursor === null) ? null : (
              <LoadMore
                onClick={() =>
                  fetchMore({
                    variables: {
                      end: community.inbox.pageInfo.endCursor
                    },
                    updateQuery: (previousResult, { fetchMoreResult }) => {
                      const newNodes = fetchMoreResult.community.inbox.edges;
                      const pageInfo = fetchMoreResult.community.inbox.pageInfo;
                      return newNodes.length
                        ? {
                            // Put the new comments at the end of the list and update `pageInfo`
                            // so we have the new `endCursor` and `hasNextPage` values
                            community: {
                              ...previousResult.community,
                              __typename: previousResult.community.__typename,
                              inbox: {
                                ...previousResult.community.inbox,
                                edges: [
                                  ...previousResult.community.inbox.edges,
                                  ...newNodes
                                ]
                              },
                              pageInfo
                            }
                          }
                        : {
                            community: {
                              ...previousResult.community,
                              __typename: previousResult.community.__typename,
                              inbox: {
                                ...previousResult.community.inbox,
                                edges: [...previousResult.community.inbox.edges]
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
          <div style={{ display: 'flex' }}>{collections}</div>
        </TabPanel>
        <TabPanel>
          {community.followed ? (
            <Discussion
              localId={community.localId}
              id={community.id}
              threads={community.threads}
              followed
              match={match}
            />
          ) : (
            <>
              <Discussion
                localId={community.localId}
                id={community.id}
                threads={community.threads}
              />
              <Footer>
                <Trans>Join the community to discuss</Trans>
              </Footer>
            </>
          )}
        </TabPanel>
      </Tabs>
    </OverlayTab>
  </WrapperTab>
);

const Name = styled.span`
  font-weight: 600;
  color: ${props => props.theme.styles.colour.base2};
  &:hover {
    text-decoration: underline;
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
