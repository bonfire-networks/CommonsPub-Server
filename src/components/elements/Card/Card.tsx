import * as React from 'react';

import styled from '../../../themes/styled';
import Button from '../Button/Button';
import slugify from '../../../util/slugify';
import { Link } from 'react-router-dom';

export enum CardType {
  community = 'community',
  collection = 'collection',
  resource = 'resource'
}

const CardLink = styled(Link)`
  text-decoration: none;
`;

const StyledCard = styled.div<any>`
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

  &.small {
    width: 260px;
    min-width: 260px;
    max-width: 260px;
    height: 195px;
  }

  &.large {
    width: 450px;
    min-width: 450px;
    max-width: 450px;
    height: 320px;
  }
`;

const CardTitle = styled.div<{ small?: boolean }>`
  font-size: ${props => (props.small ? 18 : 32)}px;
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

const typeSlug = {
  [CardType.collection]: 'collections',
  [CardType.community]: 'communities',
  [CardType.resource]: 'resources'
};

//TODO split this into separate props interfaces for each card type as it is becoming cumbersome and not useful for actual type checking anymore
export interface CardProps {
  title: string;
  backgroundImage?: string;
  onButtonClick: Function;
  contentCounts?: object;
  type?: CardType | string;
  joined?: boolean;
  likesCount?: number;
  source?: string;
  large?: boolean;
  link?: boolean | string;
}

export function CommunityCard({ ...props }: CardProps) {
  return <Card type={CardType.community} {...props} />;
}

export function CollectionCard({ ...props }: CardProps) {
  return <Card type={CardType.collection} {...props} />;
}

/**
 *
 * @param title
 * @param source
 * @param link
 * @param likesCount
 * @param backgroundImage
 * @constructor
 */
export function ResourceCard({
  title,
  source,
  link = true,
  likesCount,
  backgroundImage
}: CardProps) {
  //TODO lift this Outer stuff as it is shared with the Card component
  const Outer = link ? CardLink : React.Fragment;
  const outerProps = link
    ? {
        to:
          typeof link === 'string'
            ? link
            : `/${typeSlug[CardType.resource]}/${slugify(title)}`
      }
    : {};
  return (
    <Outer {...outerProps}>
      <StyledCard className="small" backgroundImage={backgroundImage}>
        <CardTitle small>{title}</CardTitle>
        <ResourceBottom>
          <Link to={source as any}>
            <div>Source</div>
          </Link>
          <div>{likesCount} likes</div>
        </ResourceBottom>
      </StyledCard>
    </Outer>
  );
}

/**
 *
 * @param type
 * @param joined
 * @param large
 * @param link
 * @param title
 * @param source
 * @param likesCount
 * @param backgroundImage
 * @param onButtonClick
 * @param contentCounts
 * @constructor
 */
export default function Card({
  type,
  joined = false,
  large = false,
  link = true,
  title,
  source,
  likesCount,
  backgroundImage,
  onButtonClick,
  contentCounts
}: CardProps) {
  type = String(type);

  const countKeys = contentCounts ? Object.keys(contentCounts) : [];

  const buttonText = {
    [CardType.collection]: ['Follow', 'Following'],
    [CardType.community]: ['Join', 'Member']
  }[type][+joined];

  const Outer = link ? CardLink : React.Fragment;
  const outerProps = link
    ? {
        to:
          typeof link === 'string'
            ? link
            : `/${typeSlug[type]}/${slugify(title)}`
      }
    : {};

  if (title.length > 50) {
    title = title.substr(0, 50) + '...';
  }

  return (
    <Outer {...outerProps}>
      <StyledCard
        title={title}
        className={large ? 'large' : 'small'}
        backgroundImage={backgroundImage}
      >
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
    </Outer>
  );
}
