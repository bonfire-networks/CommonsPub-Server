import * as React from 'react';
import CommentPreview from './CommentPreview';
import Talk from '../../elements/Talk/Thread';
import TalkCollection from '../../elements/Talk/ThreadCollection';
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
                    width={40}
                    height={40}
                    strokeWidth={1}
                    color={'#282828'}
                  />
                </span>
                <Trans>Start a new thread</Trans>
              </Create>
            </Actions>
          ) : null}

          {props.threads ? (
            props.threads.edges.map((comment, i) => {
              let author = {
                id: comment.node.author ? comment.node.author.id : null,
                name: comment.node.author
                  ? comment.node.author.name
                  : 'Deleted User',
                icon: comment.node.author ? comment.node.author.icon : ''
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
        props.threads.__typename.includes('Collection') ? (
          <TalkCollection
            full
            id={props.localId}
            thread
            onSelectedThread={props.onSelectedThread}
            externalId={props.id}
          />
        ) : (
          <Talk
            full
            id={props.localId}
            thread
            onSelectedThread={props.onSelectedThread}
            externalId={props.id}
          />
        )
      ) : null}
    </div>
  );
};

export default compose(withState('selectedThread', 'onSelectedThread', null))(
  CommunitiesFeatured
);
