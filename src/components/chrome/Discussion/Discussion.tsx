import * as React from 'react';
import styled from '../../../themes/styled';
import CommentPreview from './CommentPreview';
import Talk from '../../elements/Talk/Thread';
import { compose, withState } from 'recompose';
// import Text from '../../inputs/Text/Text';
// import { Globe, Star, Reply } from '../../elements/Icons';
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
                    />
                  </Previews>
                );
              })
            ) : (
              <OverviewCollection />
            )}
          </WrapperComments>
        ) : props.selectedThread === 'thread' ? (
          <Talk full id={props.localId} thread externalId={props.id} />
        ) : null}
      </Grid>
    </div>
  );
};

// const Header = styled.div`
// border-bottom: 1px solid #edf0f2;
// ${clearFix()}
// `

// const LeftArr = styled.span`
// display: inline-block;
// margin-bottom: 0;
// text-align: center;
// vertical-align: middle;
// cursor: pointer;
// white-space: nowrap;
// line-height: 20px;
// border-radius: 4px;
// user-select: none;
// color: #667d99;
// background-color: rgb(231, 237, 243);
// border: 0;
// width: 36px;
// text-align: center;
// padding: 5px;
// z-index: 3 !important;
// border-radius: 4px !important;
// transition: border-radius .2s;
// max-width: 150px;
// overflow: hidden;
// text-overflow: ellipsis;
// padding-left: 8px;
// padding-right: 8px;
// position: relative;
// background-color: #d7dfea;
// margin: 8px;
// margin-right:0;
// float:left;
// & svg {
//   vertical-align: middle;
// }
// `
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

// const Wrapper = styled.div`
//   background: white;
//   position: relative;
//   & a {
//     text-decoration: none;
//   }
// `;

export default compose(withState('selectedThread', 'onSelectedThread', null))(
  CommunitiesFeatured
);
