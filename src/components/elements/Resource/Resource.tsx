import * as React from 'react';
import styled from '../../../themes/styled';

import { Trans } from '@lingui/macro';

import { ellipsis } from 'polished';
import H5 from '../../typography/H5/H5';
import P from '../../typography/P/P';
import Button from '../Button/Button';
import { compose, withState, withHandlers } from 'recompose';
import EditResourceModal from '../EditResourceModal';
interface Props {
  icon: string;
  title: string;
  summary: string;
  url: string;
  localId: string;
  editResource(): boolean;
  isEditResourceOpen: boolean;
  preview?: boolean;
}

const ResourceCard: React.SFC<Props> = props => (
  <Wrapper>
    <Img style={{ backgroundImage: `url(${props.icon})` }} />
    <Info>
      <TitleWrapper>
        <Title>{props.title}</Title>
        {props.preview ? null : (
          <Actions>
            <Button hovered onClick={props.editResource}>
              <Trans>Edit</Trans>
            </Button>
          </Actions>
        )}
      </TitleWrapper>
      <Url>
        <a target="blank" href={props.url}>
          {props.url}
        </a>
      </Url>
      <Summary>{props.summary}</Summary>
    </Info>
    <EditResourceModal
      toggleModal={props.editResource}
      modalIsOpen={props.isEditResourceOpen}
      id={props.localId}
      url={props.url}
      image={props.icon}
      name={props.title}
      summary={props.summary}
    />
  </Wrapper>
);

const TitleWrapper = styled.div`
  display: flex;
`;
const Info = styled.div`
  flex: 1;
  margin-left: 16px;
`;
const Url = styled.div`
  margin-bottom: 8px;
  & a {
    font-size: 14px;
    color: #9e9e9e;
    font-weight: 500;
    text-decoration: none;
    ${ellipsis('420px')} margin-top: 4px;
    &:hover {
      text-decoration: underline;
    }
  }
`;

const Wrapper = styled.div`
  background: #fff;
  background-radius: 4px;
  border: 1px solid rgba(0, 0, 0, 0.15);
  padding: 24px;
  border-radius: 4px;
  display: flex;
  margin-bottom: 8px;
`;

const Img = styled.div`
  background-size: cover;
  background-repeat: none;
  height: 80px;
  width: 80px;
  border-radius: 2px;
  background-position: center center;
`;
const Title = styled(H5)`
  margin: 0 !important;
  font-size: 16px !important;
  line-height: 16px !important;
  margin-top: 8px;
  flex: 1;
`;
const Summary = styled(P)`
  margin: 0 !important;
  margin-top: 4px;
  color: #757575;
  font-size: 14px;
`;
const Actions = styled.div`
  width: 100px;
  text-align: right;
  & button {
    height: 25x;
    max-width: 80px;
    min-width: 80px;
    border-width: 1px !important;
    line-height: 25px;
  }
`;

export default compose(
  withState('isEditResourceOpen', 'onEditResourceOpen', false),
  withHandlers({
    addNewResource: props => () => props.onOpen(!props.isOpen),
    editCollection: props => () =>
      props.onEditCollectionOpen(!props.isEditCollectionOpen),
    editResource: props => () =>
      props.onEditResourceOpen(!props.isEditResourceOpen)
  })
)(ResourceCard);
