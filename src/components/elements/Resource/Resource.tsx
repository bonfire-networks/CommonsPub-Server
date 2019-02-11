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
  isEditable?: boolean;
}

const ResourceCard: React.SFC<Props> = props => {
  console.log(props);
  return (
    <Wrapper>
      <a target="blank" href={props.url}>
        <Img style={{ backgroundImage: `url(${props.icon})` }} />
      </a>
      <Info>
        <TitleWrapper>
          <a target="blank" href={props.url}>
            <Title>{props.title}</Title>
          </a>
          {!props.isEditable ? null : (
            <Actions>
              <Button hovered onClick={props.editResource}>
                <Trans>Edit</Trans>
              </Button>
            </Actions>
          )}
        </TitleWrapper>
        <a target="blank" href={props.url}>
          <Url>{props.url}</Url>
        </a>
        <Summary>
          {props.summary.split('\n').map(function(item, key) {
            return (
              <span key={key}>
                {item}
                <br />
              </span>
            );
          })}
        </Summary>
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
};

const TitleWrapper = styled.div`
  display: flex;
  & a {
    flex: 1;
  }
`;
const Info = styled.div`
  flex: 1;
  margin-left: 16px;
  & a {
    text-decoration: none;
    color: inherit;
  }
`;
const Url = styled.div`
  margin-bottom: 8px;
  font-size: 14px;
  color: #9e9e9e;
  font-weight: 500;
  ${ellipsis('420px')} margin-top: 4px;
  &:hover {
    text-decoration: underline;
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
  height: 120px;
  width: 120px;
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
    editResource: props => () =>
      props.onEditResourceOpen(!props.isEditResourceOpen)
  })
)(ResourceCard);
