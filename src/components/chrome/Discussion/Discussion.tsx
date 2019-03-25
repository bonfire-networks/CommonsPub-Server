import * as React from 'react';
import styled from '../../../themes/styled';
import CommentPreview from './CommentPreview';
import Talk from '../../elements/Talk/Thread';
import { compose, withState } from 'recompose';
import { Send } from '../../elements/Icons';
import media from 'styled-media-query';

import { Trans } from '@lingui/macro';
import { clearFix } from 'polished';
interface Props {
  threads: any;
  localId: string;
  id: string;
  followed?: boolean;
  selectedThread: any;
  type: string;
  match: any;
  onSelectedThread(any): number;
}

const CommunitiesFeatured: React.SFC<Props> = props => {
  return (
    <div style={{ height: '100%' }}>
      <Grid>
        {props.selectedThread === null ? (
          <WrapperComments
            selected={props.selectedThread === null ? false : true}
          >
            {props.followed ? (
              <Actions>
                <ThreadButton onClick={() => props.onSelectedThread('thread')}>
                  <span>
                    <Send
                      width={18}
                      height={18}
                      strokeWidth={2}
                      color={'#f0f0f0'}
                    />
                  </span>
                  <Trans>Start a new thread</Trans>
                </ThreadButton>
              </Actions>
            ) : null}

            {props.threads ? (
              props.threads.edges.map((comment, i) => {
                let author = {
                  id: comment.node.author.id,
                  name: comment.node.author.name,
                  icon: comment.node.author.icon
                };
                let message = {
                  body: comment.node.content,
                  date: comment.node.published,
                  id: comment.node.localId
                };
                return (
                  <Previews key={i}>
                    <CommentPreview
                      totalReplies={comment.node.replies.totalCount}
                      key={comment.node.id}
                      author={author}
                      comment={message}
                      selectThread={props.onSelectedThread}
                      selectedThread={props.selectedThread}
                      communityId={props.localId}
                      type={props.type}
                    />
                  </Previews>
                );
              })
            ) : (
              <OverviewCollection />
            )}
          </WrapperComments>
        ) : props.selectedThread === 'thread' ? (
          <Talk
            full
            id={props.localId}
            thread
            onSelectedThread={props.onSelectedThread}
            externalId={props.id}
          />
        ) : null}
      </Grid>
    </div>
  );
};

const Previews = styled.div``;

const Actions = styled.div`
  ${clearFix()};
  display: flex;
  border-bottom: 1px solid #edf0f2;
  span {
    & svg {
      vertical-align: middle;
      margin-right: 16px;
    }
  }
`;

const ThreadButton = styled.div`
  border-radius: 4px;
  background: ${props => props.theme.styles.colour.primary};
  font-size: 13px;
  font-weight: 600;
  line-height: 35px;
  text-align: center;
  cursor: pointer;
  color: #f0f0f0;
  margin: 8px;
  float: left;
  padding: 0 16px;
  display: inline-block;
  & span {
    & svg {
      vertical-align: middle;
    }
  }
`;

const WrapperComments = styled.div<{ selected?: boolean }>`
  // background: #e9ebef;
  border-right: 1px solid #e2e5ea;
  ${media.lessThan('medium')`
  display: ${props => (props.selected ? 'none' : 'auto')};
`};
`;

const Grid = styled.div`
  display: grid;
  grid-template-columns: 1fr;
  height: 100%;

  ${media.lessThan('medium')`
    grid-template-columns: 1fr;
   `};
`;

const OverviewCollection = styled.div`
  padding: 0 8px;
  & p {
    margin-top: 0 !important;
  }
`;

export default compose(withState('selectedThread', 'onSelectedThread', null))(
  CommunitiesFeatured
);
