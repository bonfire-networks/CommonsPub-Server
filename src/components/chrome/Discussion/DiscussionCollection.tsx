import * as React from 'react';
import styled from '../../../themes/styled';
import CommentPreview from './CommentPreview';
import Talk from '../../elements/Talk/ThreadCollection';
import { compose, withState } from 'recompose';
import Thread from '../../../pages/thread';
// import Text from '../../inputs/Text/Text';
// import { Globe, Star, Reply } from '../../elements/Icons';
import { Send } from '../../elements/Icons';

import { Trans } from '@lingui/macro';
interface Props {
  threads: any;
  localId: string;
  id: string;
  followed?: boolean;
  selectedThread: any;
  onSelectedThread(any): number;
}

// const Search = props => (
//   <Text
//    placeholder="Search threads..."
//   />
// )

const CommunitiesFeatured: React.SFC<Props> = props => {
  return (
    <div style={{ height: '100%' }}>
      {/* {props.followed ? (
        <Talk id={props.localId} externalId={props.id} />
      ) : null} */}
      <Grid>
        <WrapperComments>
          <ThreadButton onClick={() => props.onSelectedThread('thread')}>
            <span>
              <Send width={18} height={18} strokeWidth={2} color={'#f0f0f0'} />
            </span>
            <Trans>Start a new thread</Trans>
          </ThreadButton>
          {/* <Filter>
          <Cont><span><Globe width={18} height={18} strokeWidth={2} color={"#f0f0f0"} /></span></Cont>
          <Cont><span><Star width={18} height={18} strokeWidth={2} color={"#f0f0f0"} /></span></Cont>
          <Cont><span><Reply width={18} height={18} strokeWidth={2} color={"#f0f0f0"} /> </span></Cont>
          <Cont><span></span></Cont>
        </Filter>
        <WrapperSearch>
        <Search />
        </WrapperSearch> */}
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
                  />
                </div>
              );
            })
          ) : (
            <OverviewCollection />
          )}
        </WrapperComments>
        <Wrapper>
          {props.selectedThread === 'thread' ? (
            <Talk full id={props.localId} externalId={props.id} />
          ) : props.selectedThread === null ? (
            <Empty>
              <Trans>Select a thread to see the discussion...</Trans>
            </Empty>
          ) : (
            <Thread
              selectThread={props.onSelectedThread}
              id={props.selectedThread}
            />
          )}
        </Wrapper>
      </Grid>
    </div>
  );
};

const Empty = styled.div`
  margin: 40px;
  border-radius: 6px;
  height: 60px;
  line-height: 60px;
  text-align: center;
  font-size: 16px;
  color: #abafb9;
  font-weight: 600;
`;

const ThreadButton = styled.div`
  height: 40px;
  margin: 8px;
  border-radius: 4px;
  background: #5a606d;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
  font-size: 14px;
  font-weight: 600;
  line-height: 40px;
  text-align: center;
  cursor: pointer;
  color: #f0f0f0;
  & span {
    display: inline-block;
    margin-right: 8px;
    & svg {
      vertical-align: middle;
    }
  }
`;

// const Filter = styled.div`
// height: 40px;
// margin: 8px;
// border-radius: 4px;
// background: #5a606d;
// box-shadow: 0 1px 2px rgba(0,0,0,.2);
// display: grid;
// grid-template-columns: 1fr 1fr 1fr 1fr;
// & div {
//   border-right:1px solid #4a4e56;
//   & span {
//     margin: 0 auto;
//     text-align: center;
//     display: block;
//     height: 40px;
//     line-height: 40px;
//     & svg {
//       vertical-align: middle;
//     }
//   }
//   &:last-of-type {
//     border-right: 0px;
//   }
// }

// `;

// const WrapperSearch = styled.div`
//   margin: 8px;
// `;

// const Cont = styled.div`

// `;

const WrapperComments = styled.div`
  background: #e9ebef;
  border-right: 1px solid #e2e5ea;
`;

const Grid = styled.div`
  display: grid;
  grid-template-columns: 1fr 2fr;
  margin-top: -20px;
  height: 100%;
`;

const OverviewCollection = styled.div`
  padding: 0 8px;
  & p {
    margin-top: 0 !important;
  }
`;

const Wrapper = styled.div`
  background: white;
  position: relative;
  & a {
    text-decoration: none;
  }
`;

export default compose(withState('selectedThread', 'onSelectedThread', null))(
  CommunitiesFeatured
);
