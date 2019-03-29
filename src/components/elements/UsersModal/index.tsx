import * as React from 'react';
import Modal from '../Modal';
import styled from '../../../themes/styled';
import media from 'styled-media-query';

import { Trans } from '@lingui/macro';
import Link from '../../elements/Link/Link';
import H4 from '../../typography/H4/H4';

import { clearFix } from 'polished';
import H5 from '../../typography/H5/H5';

interface Props {
  toggleModal?: any;
  modalIsOpen?: boolean;
  members: any;
}

const CreateCommunityModal = (props: Props) => {
  const { toggleModal, modalIsOpen, members } = props;
  return (
    <Modal isOpen={modalIsOpen} toggleModal={() => toggleModal(false)}>
      <Container>
        <Header>
          <H5>
            <Trans>Community Members</Trans>
          </H5>
        </Header>
        <Members>
          {members.map((edge, i) => (
            <Follower key={i}>
              <Link to={'/user/' + edge.node.localId}>
                <Img
                  style={{
                    backgroundImage: `url(${edge.node.icon})`
                  }}
                />
                <FollowerName>{edge.node.name}</FollowerName>
              </Link>
            </Follower>
          ))}
        </Members>
      </Container>
    </Modal>
  );
};

export default CreateCommunityModal;

const Container = styled.div`
  font-family: ${props => props.theme.styles.fontFamily};
`;

const Members = styled.div`
  ${clearFix()};
  padding: 0 12px;
  margin-top: 16px;
  margin-bottom: 16px;
  display: grid;
  grid-template-columns: 1fr 1fr 1fr 1fr 1fr;
  grid-column-gap: 8px;
  grid-row-gap: 8px;
  ${media.lessThan('medium')`
  grid-template-columns: 1fr 1fr 1fr;
`};
`;
const Follower = styled.div`
  & a {
    text-decoration: none;
  }
`;

const Img = styled.div`
  height: 100px;
  margin: 0 auto;
  display: block;
  background-size: cover;
  background-repeat: no-repeat;
  background-position: center center;
  background-color: #dadada;
  width: 50%;
  height: 0;
  padding: 25%;
  border-radius: 100px;
  border: 5px solid #eceaea;
`;
const FollowerName = styled(H4)`
  margin-top: 8px !important;
  text-align: center;
  font-size: 14px !important;
  line-height: 20px !important;
  text-decoration: none;
  color: ${props => props.theme.styles.colour.base1};
  &:hover {
    color: ${props => props.theme.styles.colour.primary};
  }
`;
const Header = styled.div`
  height: 60px;
  border-bottom: 1px solid rgba(151, 151, 151, 0.2);
  & h5 {
    text-align: center !important;
    line-height: 60px !important;
    margin: 0 !important;
    color: ${props => props.theme.styles.colour.base1};
  }
`;
