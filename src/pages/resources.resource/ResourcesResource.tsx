// import * as React from 'react';
// import { Grid, Row, Col } from '@zendeskgarden/react-grid';
//
// import styled from '../../themes/styled';
// import Link from '../../components/elements/Link/Link';
// import Logo from '../../components/brand/Logo/Logo';
// import slugify from '../../util/slugify';
// import Main from '../../components/chrome/Main/Main';
// import P from '../../components/typography/P/P';
// import { DUMMY_RESOURCES } from '../../__DEV__/dummy-cards';
// import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
// import { faHeart } from '@fortawesome/free-solid-svg-icons';
//
// const BoldP = styled(P)`
//   font-weight: bold;
//   display: flex;
//
//   p:first-child {
//     flex-grow: 1;
//   }
// `;
//
// const ResourceImage = styled.div<any>`
//   width: 100%;
//   height: 300px;
//   margin-top: 1em;
//   background-image: url(${props => props.image});
//   background-size: 100% auto;
//   background-position: center;
// `;
//
// const resource = DUMMY_RESOURCES[0];
//
// enum TabsEnum {
//   Collections = 'Collections',
//   Discussion = 'Discussion'
// }
//
// export default class ResourcesResource extends React.Component {
//   state = {
//     tab: TabsEnum.Collections
//   };
//
//   render() {
//     return (
//       <>
//         <Main>
//           <Grid>
//             <Row>
//               <Col sm={6}>
//                 <Logo />
//               </Col>
//             </Row>
//             <Row>
//               <Col size={6}>
//                 Collection by{' '}
//                 <Link
//                   to={`/communities/${slugify(
//                     resource.collection.community.title
//                   )}`}
//                 >
//                   {resource.collection.community.title}
//                 </Link>
//                 {' > '}
//                 <Link to={`/collections/${slugify(resource.collection.title)}`}>
//                   {resource.collection.title}
//                 </Link>
//               </Col>
//             </Row>
//             <Row>
//               <Col size={6}>
//                 <h4>{resource.title}</h4>
//                 <ResourceImage image={resource.backgroundImage} />
//                 <BoldP>
//                   <P>Description</P>
//                   <P>
//                     {resource.likesCount} <FontAwesomeIcon icon={faHeart} />
//                   </P>
//                 </BoldP>
//                 <P>{resource.description}</P>
//               </Col>
//             </Row>
//           </Grid>
//         </Main>
//       </>
//     );
//   }
// }
