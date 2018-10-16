import * as React from 'react';

import styled from '../../../themes/styled';
import Button from '../Button/Button';
import { Link } from 'react-router-dom';

export enum CardType {
  community = 'community',
  collection = 'collection',
  resource = 'resource'
}

const StyledCard = styled.div<any>`
  width: 260px;
  min-width: 260px;
  max-width: 260px;
  height: 195px;
  background-color: white;
  padding: 15px;
  overflow: hidden;
  background-image: linear-gradient(transparent, rgba(0, 0, 0, 0.75)),
    url(${props => props.backgroundImage});
  background-size: cover;
  background-repeat: no-repeat;
  color: white;
  display: flex;
  flex-direction: column;
  margin: 0 15px 15px 0;
`;

const CardTitle = styled.div<{ small?: boolean }>`
  font-size: ${props => (props.small ? 20 : 32)}px;
  font-weight: bold;
  flex-grow: 1;
`;

const ContentCounts = styled.div`
  margin: 10px 0;
`;

// TODO fix hover styles for buttons in Card
// TODO fix so we don't use !important here
const CardButton = styled(Button)<any>`
  color: ${props =>
    props.type === CardType.collection ? 'white' : ''} !important;
  border-color: ${props =>
    props.type === CardType.collection ? 'white' : ''} !important;
  text-transform: uppercase;
`;

const ResourceBottom = styled.div`
  display: flex;

  a,
  a:hover,
  a:focus,
  a:active {
    color: white;
    text-decoration: none;
  }

  div:nth-child(2) {
    display: flex;
    justify-content: flex-end;
    flex-grow: 1;
  }
`;

export type CardProps = {
  title: string;
  backgroundImage?: string;
  onButtonClick: Function;
  contentCounts?: object;
  type?: CardType;
  joined?: boolean;
  likesCount?: number;
  source?: string;
};

export function CommunityCard({ ...props }: CardProps) {
  return <Card type={CardType.community} {...props} />;
}

export function CollectionCard({ ...props }: CardProps) {
  return <Card type={CardType.collection} {...props} />;
}

export function ResourceCard({
  title,
  source,
  likesCount,
  backgroundImage
}: CardProps) {
  return (
    <StyledCard backgroundImage={backgroundImage}>
      <CardTitle small>{title}</CardTitle>
      <ResourceBottom>
        <Link to={source as any}>
          <div>Source</div>
        </Link>
        <div>{likesCount} likes</div>
      </ResourceBottom>
    </StyledCard>
  );
}

export default function Card({
  title,
  type = CardType.collection,
  joined = false,
  source,
  likesCount,
  backgroundImage,
  onButtonClick,
  contentCounts
}: CardProps) {
  const countKeys = contentCounts ? Object.keys(contentCounts) : [];

  const buttonText = {
    [CardType.collection]: ['Follow', 'Following'],
    [CardType.community]: ['Join', 'Member']
  }[type][+joined];
  //TODO ^^^ how to not do String() on type when using as index?

  return (
    <StyledCard backgroundImage={backgroundImage}>
      <CardTitle>{title}</CardTitle>
      {contentCounts ? (
        <ContentCounts>
          {countKeys.map((key, i) => {
            let separator: JSX.Element | null = null;
            if (i < countKeys.length - 1 && countKeys.length > 1) {
              separator = <span> &bull; </span>;
            }
            return (
              <span key={i}>
                {contentCounts[key]} {key}
                {separator}
              </span>
            );
          })}
        </ContentCounts>
      ) : null}
      <div>
        <CardButton
          type={type}
          hovered={type === CardType.community}
          secondary={type === CardType.collection}
          onClick={onButtonClick as any /*TODO don't use any type*/}
        >
          {buttonText}
        </CardButton>
      </div>
    </StyledCard>
  );
}
