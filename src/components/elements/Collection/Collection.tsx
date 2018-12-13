import * as React from 'react';
import styled from '../../../themes/styled';
import Collection from '../../../types/Collection';
import H5 from '../../typography/H5/H5';
import P from '../../typography/P/P';
import { Link } from 'react-router-dom';

interface CollectionProps {
  collection: Collection;
  communityId: string;
}

const Collection: React.SFC<CollectionProps> = ({
  collection,
  communityId
}) => {
  return (
    <Wrapper>
      <Link
        to={`/communities/${communityId}/collections/${collection.localId}`}
      >
        <Img style={{ backgroundImage: `url(${collection.icon})` }} />
        <Infos>
          <Title>{collection.name}</Title>
          <Desc>{collection.summary}</Desc>
          <Actions>
            <ActionItem>{collection.followersCount} Followers</ActionItem>
            <ActionItem>{collection.resourcesCount || 0} Resources</ActionItem>
          </Actions>
        </Infos>
      </Link>
    </Wrapper>
  );
};

const Actions = styled.div`
  margin-top: 20px;
`;
const ActionItem = styled.div`
  display: inline-block;
  font-size: 12px;
  font-weight: 600;
  color: #8b98a2;
  text-transform: uppercase;
  margin-right: 20px;
`;

const Wrapper = styled.div`
  display: flex;
  border-bottom: 1px solid #ebe8e8;
  padding: 10px;
  cursor: pointer;
  & a {
    display: flex;
    color: inherit;
    text-decoration: none;
  }
  &:hover {
    background: #f5f5f5;
  }
`;
const Img = styled.div`
  width: 55px;
  height: 55px;
  border-radius: 2px;
  background-size: cover;
  background-repeat: no-repeat;
  background-color: #f0f0f0;
  margin-right: 10px;
`;
const Infos = styled.div`
  flex: 1;
`;
const Title = styled(H5)`
  font-size: 14px !important;
  margin: 0 !important;
  line-height: 20px !important;
  letter-spacing: 0.8px;
`;
const Desc = styled(P)`
  margin: 0 !important;
  font-size: 14px !important;
`;

export default Collection;
