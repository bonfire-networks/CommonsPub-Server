// import * as React from 'react';

// import { Trans } from '@lingui/macro';

// import { faHeart } from '@fortawesome/free-solid-svg-icons';
// import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

// import styled from '../../../themes/styled';
// import Button from '../Button/Button';
// import slugify from '../../../util/slugify';
// import Community from '../../../types/Community';
// import Collection from '../../../types/Collection';
// import Resource from '../../../types/Resource';
// import { Link } from 'react-router-dom';

// export enum CardType {
//   community = 'community',
//   collection = 'collection',
//   resource = 'resource'
// }

// const CardLink = styled(Link)`
//   text-decoration: none;
// `;

// const StyledCard = styled.div<any>`
//   background-color: white;
//   padding: 15px;
//   overflow: hidden;
//   background-image: linear-gradient(transparent, rgba(0, 0, 0, 0.75)),
//     url(${props => props.backgroundImage});
//   background-size: cover;
//   background-repeat: no-repeat;
//   color: white;
//   display: flex;
//   flex-direction: column;
//   margin: 0 15px 15px 0;

//   &.small {
//     width: 260px;
//     min-width: 260px;
//     max-width: 260px;
//     height: 195px;
//   }

//   &.large {
//     width: 450px;
//     min-width: 450px;
//     max-width: 450px;
//     height: 320px;
//   }
// `;

// const CardTitle = styled.div<{ small?: boolean }>`
//   font-size: ${props => (props.small ? 18 : 32)}px;
//   font-weight: bold;
//   flex-grow: 1;
// `;

// const ContentCountsContainer = styled.div`
//   margin: 10px 0;
// `;

// // TODO fix hover styles for buttons in Card
// // TODO fix so we don't use !important here
// const CardButton = styled(Button)<any>`
//   color: ${props =>
//     props.type === CardType.collection ? 'white' : ''} !important;
//   border-color: ${props =>
//     props.type === CardType.collection ? 'white' : ''} !important;
//   text-transform: uppercase;
// `;

// const ResourceBottom = styled.div`
//   display: flex;
//   align-items: center;

//   a,
//   a:hover,
//   a:focus,
//   a:active {
//     color: white;
//     text-decoration: none;
//   }

//   // likes
//   div:nth-child(2) {
//     align-items: center;
//     display: flex;
//     justify-content: flex-end;
//     flex-grow: 1;
//   }
// `;

// const typeSlug = {
//   [CardType.collection]: 'collections',
//   [CardType.community]: 'communities',
//   [CardType.resource]: 'resources'
// };

// //TODO split this into separate props interfaces for each card type as it is becoming cumbersome and not useful for actual type checking anymore
// export interface SubCardProps {
//   key?: any;
//   onButtonClick?: Function;
//   large?: boolean;
//   link?: boolean | string;
//   following?: boolean;
//   entity: Community | Collection | Resource;
// }

// export interface CardProps {
//   key?: any;
//   onButtonClick?: Function;
//   type: CardType;
//   large?: boolean;
//   link?: boolean | string;
//   following?: boolean;
//   entity: Community | Collection | Resource;
// }

// /**
//  * Card component for a community.
//  * @param props {Object} community card props
//  * @constructor
//  */
// export function CommunityCard({ ...props }: SubCardProps) {
//   return <Card type={CardType.community} {...props} />;
// }

// /**
//  * Card component for a collection.
//  * @param props {Object} collection card props
//  * @constructor
//  */
// export function CollectionCard({ ...props }: SubCardProps) {
//   return <Card type={CardType.collection} {...props} />;
// }

// export interface ResourceCardProps {
//   key?: any;
//   onButtonClick?: Function;
//   large?: boolean;
//   link?: boolean | string;
//   following?: boolean;
//   entity: Resource;
// }

// /**
//  * Card component for a resource.
//  * @param entity {Resource} resource entity
//  * @param link {string} card anchor href
//  * @constructor
//  */
// export function ResourceCard({ entity, link = true }: ResourceCardProps) {
//   const Outer = makeCardOuterComponent({
//     link,
//     type: CardType.resource,
//     entity: entity
//   });
//   return (
//     <Outer>
//       <StyledCard className="small" backgroundImage={entity.icon}>
//         <CardTitle small>{entity.name}</CardTitle>
//         <ResourceBottom>
//           <a target="_blank" href={entity.source}>
//             Source
//           </a>
//           <ContentCounts type={CardType.resource} entity={entity} />
//         </ResourceBottom>
//       </StyledCard>
//     </Outer>
//   );
// }

// /**
//  * Generic card component.
//  * @param type {CardType} type of card
//  * @param following {Boolean} is the user following whatever the card represents
//  * @param large {Boolean} should the card appear as large
//  * @param link {}
//  * @param onButtonClick
//  * @param entity
//  * @constructor
//  */
// export default function Card({
//   type,
//   large = false,
//   link = true,
//   following = false,
//   entity,
//   onButtonClick
// }: CardProps) {
//   const Outer = makeCardOuterComponent({ type, link, entity });

//   const buttonText = {
//     [CardType.collection]: ['Follow', 'Following'],
//     [CardType.community]: ['Join', 'Member']
//   }[String(type)][+following];

//   let title = entity.name;
//   if (entity.name.length > 50) {
//     title = title.substr(0, 50) + '...';
//   }

//   return (
//     <Outer>
//       <StyledCard
//         title={title}
//         className={large ? 'large' : 'small'}
//         backgroundImage={entity.icon}
//       >
//         <CardTitle>{title}</CardTitle>
//         <ContentCounts type={type} entity={entity} />
//         <div>
//           <CardButton
//             type={type}
//             hovered={type === CardType.community}
//             secondary={type === CardType.collection}
//             onClick={onButtonClick ? onButtonClick : () => {}}
//           >
//             {buttonText}
//           </CardButton>
//         </div>
//       </StyledCard>
//     </Outer>
//   );
// }

// type ContentCountsProps = {
//   entity: Community | Collection | Resource;
//   type: CardType | string;
// };

// /**
//  * Component that renders the "following" count or other
//  * relevant metrics for a card.
//  * @param entity {Object} entity the card represents, e.g. community or resource
//  * @param type {CardType} type of the entity the card represents
//  * @constructor
//  */
// function ContentCounts({
//   entity,
//   type
// }: ContentCountsProps): JSX.Element | null {
//   if (type === CardType.collection) {
//     entity = entity as Collection;
//     return (
//       <ContentCountsContainer>
//         {entity.followingCount} <Trans>Members</Trans> &bull;{' '}
//         {entity.resourcesCount} <Trans>Resources</Trans>
//       </ContentCountsContainer>
//     );
//   } else if (type === CardType.community) {
//     entity = entity as Community;
//     return (
//       <ContentCountsContainer>
//         {entity.followingCount} <Trans>Members</Trans> &bull;{' '}
//         {entity.collectionsCount} Collections
//       </ContentCountsContainer>
//     );
//   } else if (type === CardType.resource) {
//     entity = entity as Resource;
//     return (
//       <ContentCountsContainer>
//         {entity.likesCount} <FontAwesomeIcon icon={faHeart} color="red" />
//       </ContentCountsContainer>
//     );
//   }
//   return null;
// }

// /**
//  * Make a Card component wrapper, such as a Link.
//  * @param type {CardType} the card component type
//  * @param link {String|Boolean} if true, generates link to entity, otherwise uses link directly as href of Link
//  * @param entity {Object} the entity that the card represents, e.g. a community or resource
//  */
// function makeCardOuterComponent({ type, link, entity }) {
//   //TODO lift this Outer stuff as it is shared with the Card component
//   const Outer = link ? CardLink : React.Fragment;
//   const outerProps = link
//     ? {
//         to:
//           typeof link === 'string'
//             ? link
//             : // TODO use preferredUsername instead of localId when it is available
//               `/${typeSlug[type]}/${slugify(entity.localId)}`
//       }
//     : {};
//   return ({ children }) => <Outer {...outerProps}>{children}</Outer>;
// }
