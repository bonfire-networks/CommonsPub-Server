import * as React from 'react';
import CommentPreview from './CommentPreview';
import Talk from '../../elements/Talk/Thread';
import { compose, withState } from 'recompose';
import { Send } from '../../elements/Icons';
import {
  Actions,
  Create
} from '../../../pages/communities.community/CommunitiesCommunity';
import { Trans } from '@lingui/macro';

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
    <div>
      {props.selectedThread === null ? (
        <>
          {props.followed ? (
            <Actions>
              <Create onClick={() => props.onSelectedThread('thread')}>
                <span>
                  <Send
                    width={18}
                    height={18}
                    strokeWidth={2}
                    color={'#f0f0f0'}
                  />
                </span>
                <Trans>Start a new thread</Trans>
              </Create>
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
                <div key={i}>
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
                </div>
              );
            })
          ) : (
            <div />
          )}
        </>
      ) : props.selectedThread === 'thread' ? (
        <Talk
          full
          id={props.localId}
          thread
          onSelectedThread={props.onSelectedThread}
          externalId={props.id}
        />
      ) : null}
    </div>
  );
};

export default compose(withState('selectedThread', 'onSelectedThread', null))(
  CommunitiesFeatured
);