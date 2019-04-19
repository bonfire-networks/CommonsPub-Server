import * as React from 'react';
import styled from '../../../themes/styled';
import Collection from '../../../types/Collection';
import { Link } from 'react-router-dom';
import Join from './Join';
import H5 from '../../typography/H5/H5';
import P from '../../typography/P/P';
import { Resource, Eye, Message } from '../Icons';
import media from 'styled-media-query';
const PlaceholderImg = require('../Icons/collectionPlaceholder.png');

interface CollectionProps {
  collection: Collection;
  communityId: string;
}

const Collection: React.SFC<CollectionProps> = ({ collection }) => {
  return (
    <Wrapper>
      <Link to={`/collections/${collection.localId}`}>
        <Img
          style={{
            backgroundImage: `url(${collection.icon || PlaceholderImg})`
          }}
        />
        <Infos>
          <Title>
            {collection.name.length > 80
              ? collection.name.replace(/^(.{76}[^\s]*).*/, '$1...')
              : collection.name}
          </Title>
          <Desc>
            {collection.summary.length > 320
              ? collection.summary.replace(
                  /^([\s\S]{316}[^\s]*)[\s\S]*/,
                  '$1...'
                )
              : collection.summary}
          </Desc>
          <Actions>
            <ActionItem>
              {(collection.resources && collection.resources.totalCount) || 0}{' '}
              <Resource
                width={18}
                height={18}
                strokeWidth={2}
                color={'#8b98a2'}
              />
            </ActionItem>
            <ActionItem>
              {(collection.followers && collection.followers.totalCount) || 0}{' '}
              <Eye width={18} height={18} strokeWidth={2} color={'#8b98a2'} />
            </ActionItem>
            <ActionItem>
              {(collection.threads && collection.threads.totalCount) || 0}{' '}
              <Message
                width={18}
                height={18}
                strokeWidth={2}
                color={'#8b98a2'}
              />
            </ActionItem>
          </Actions>
        </Infos>
      </Link>
      <Right>
        <Join
          followed={collection.followed}
          id={collection.localId}
          externalId={collection.id}
        />
      </Right>
    </Wrapper>
  );
};

const Right = styled.div`
  width: 160px;
  margin-right: 8px;
  ${media.lessThan('medium')`
  margin-top: 8px;
  background: #f7f8f9;
  border-radius: 6px;
  display: inline-block;
  margin-left: 8px;
`};
`;

const Actions = styled.div`
  margin-top: 10px;
`;
const ActionItem = styled.div`
  display: inline-block;
  font-size: 14px;
  font-weight: 600;
  color: ${props => props.theme.styles.colour.collectionIcon};
  text-transform: uppercase;
  margin-right: 20px;
  & svg {
    vertical-align: sub;
    color: inherit !important;
  }
`;

const Wrapper = styled.div`
  display: flex;
  cursor: pointer;
  padding: 8px 0;
  position: relative;
  background: ${props => props.theme.styles.colour.collectionBg};
  border-radius: 6px;
  margin-bottom: 8px;
  ${media.lessThan('medium')`
  display: block;
`} & a {
    display: flex;
    color: inherit;
    text-decoration: none;
    width: 100%;
  }
  &:hover {
    background: rgba(241, 246, 249, 0.65);
  }
`;
const Img = styled.div`
  width: 120px;
  height: 120px;
  border-radius: 8px;
  background-size: cover;
  background-repeat: no-repeat;
  // background-color: ${props => props.theme.styles.colour.secondary};
  margin-right: 8px;
  margin-left: 8px;
`;
const Infos = styled.div`
  flex: 1;
`;
const Title = styled(H5)`
  font-size: 16px !important;
  margin: 0 0 8px 0 !important;
  line-height: 20px !important;
  letter-spacing: 0.8px;
  font-weight: 600;
  color: ${props => props.theme.styles.colour.collectionTitle};
`;
const Desc = styled(P)`
  margin: 0 !important;
  font-size: 14px !important;
  color: ${props => props.theme.styles.colour.collectionNote};
  font-size: 48px;
  line-height: 20px;
`;

export default Collection;
