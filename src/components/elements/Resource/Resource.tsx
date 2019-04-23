import * as React from 'react';
import styled from '../../../themes/styled';
import { Trans } from '@lingui/macro';
import media from 'styled-media-query';
import { ellipsis } from 'polished';
import H5 from '../../typography/H5/H5';
import P from '../../typography/P/P';
import Button from '../Button/Button';
import { compose, withState, withHandlers } from 'recompose';
import EditResourceModal from '../EditResourceModal';
const PlaceholderImg = require('../Icons/resourcePlaceholder.png');

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
  return (
    <Wrapper>
      <a target="blank" href={props.url}>
        <Img
          style={{ backgroundImage: `url(${props.icon || PlaceholderImg})` }}
        />
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
        <UrlLink target="blank" href={props.url}>
          <Url>{props.url}</Url>
        </UrlLink>
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

const UrlLink = styled.a`
  ${media.lessThan('medium')`
  text-align:center;
  display: block;
`};
`;

const TitleWrapper = styled.div`
  display: flex;
  & a {
    flex: 1;
  }
`;
const Info = styled.div`
  flex: 1;
  margin-left: 8px;
  ${media.lessThan('medium')`
  margin-left: 0;
  `};
  & a {
    text-decoration: none;
    color: inherit;
  }
`;
const Url = styled.div`
  margin-bottom: 8px;
  font-size: 14px;
  color: ${props => props.theme.styles.colour.base3};
  font-weight: 400;
  ${ellipsis('420px')};
  margin-top: 8px;

  ${media.lessThan('medium')`
  ${ellipsis('210px')};
  text-align: center;
  `};
  &:hover {
    text-decoration: underline;
  }
`;

const Wrapper = styled.div`
  background: ${props => props.theme.styles.colour.resourceBg};
  border-bottom: 1px solid rgba(0, 0, 0, 0.15);
  padding: 8px;
  display: flex;
  margin-bottom: 8px;
  ${media.lessThan('medium')`
  display: block;
  padding: 0;
  padding: 8px;
  &:last-of-type {
    margin-bottom: 0;
    border-bottom: 0px;
  }
  `};
`;

const Img = styled.div`
  background-size: cover;
  background-repeat: none;
  height: 120px;
  width: 120px;
  border-radius: 2px;
  background-position: center center;
  // background-color: ${props => props.theme.styles.colour.resourceIcon};
  ${media.lessThan('medium')`
    margin: 0 auto;
    margin-bottom: 8px;
    margin-top: 8px;
  `};
`;
const Title = styled(H5)`
  margin: 0 !important;
  font-size: 16px !important;
  line-height: 16px !important;
  margin-top: 8px;
  flex: 1;
  color: ${props => props.theme.styles.colour.resourceTitle};
  ${media.lessThan('medium')`
  text-align: center;
  padding: 0 8px;
  line-height: 24px !important;
`};
`;
const Summary = styled(P)`
  margin: 0 !important;
  margin-top: 4px;
  color: ${props => props.theme.styles.colour.resourceNote}
  font-size: 13px;
  line-height: 18px;
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
    color: ${props => props.theme.styles.colour.resourceIcon} svg {
      color: inherit !important;
    }
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
