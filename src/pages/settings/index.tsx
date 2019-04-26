import * as React from 'react';
import styled from '../../themes/styled';
import { graphql, OperationOption } from 'react-apollo';
const getSettings = require('../../graphql/me.graphql');
import CommentType from '../../types/Comment';
import { compose, withState } from 'recompose';
import Loader from '../../components/elements/Loader/Loader';
import { Trans } from '@lingui/macro';
import { Helmet } from 'react-helmet';
import LanguageSelect from '../../components/inputs/LanguageSelect/LanguageSelect';
import { useTheme } from '../../styleguide/Wrapper';

import GeneralInfo from './generalInfo';

interface Props {
  data: any;
  switch: string;
  onSwitch(string): string;
}

const withGetSettings = graphql<
  {},
  {
    data: {
      comment: CommentType;
    };
  }
>(getSettings) as OperationOption<{}, {}>;

const Component = (props: Props) => {
  const { data } = props;
  const themeState = useTheme();
  if (data.error) {
    return 'error...';
  } else if (data.loading) {
    return <Loader />;
  }
  return (
    <Wrapper>
      <Helmet>
        <title>MoodleNet > Settings</title>
      </Helmet>
      <Sidebar>
        <SidebarHeader>
          <Trans>Settings</Trans>
        </SidebarHeader>
        <Item
          style={
            props.switch === 'general'
              ? { color: '#f98012' }
              : { position: 'static' }
          }
          onClick={() => props.onSwitch('general')}
        >
          <Trans>General information</Trans>
        </Item>
        <Item
          style={
            props.switch === 'preferences'
              ? { color: '#f98012' }
              : { position: 'static' }
          }
          onClick={() => props.onSwitch('preferences')}
        >
          <Trans>Preferences</Trans>
        </Item>
      </Sidebar>
      <Container>
        {props.switch === 'general' ? (
          <GeneralInfo profile={data.me} />
        ) : (
          <GenWrapper>
            <LanguageSelect />
            <Item onClick={() => themeState.toggle()}>
              {themeState.dark ? (
                <Trans>Switch to Light Mode</Trans>
              ) : (
                <Trans>Switch to Dark Mode</Trans>
              )}
            </Item>
          </GenWrapper>
        )}
      </Container>
    </Wrapper>
  );
};

const Wrapper = styled.div`
  display: flex;
  width: 1040px;
  margin: 0 auto;
  margin-top: 24px;
`;
const GenWrapper = styled.div``;

const Container = styled.div`
  box-sizing: border-box;
  flex: 1;
  margin-left: 16px;
  background: #fff;
  border-radius: 6px;
`;

const Item = styled.span`
  display: block;
  height: 40px;
  line-height: 40px;
  font-size: 14px;
  cursor: pointer;
  padding: 0 8px;
  color: ${props => props.theme.styles.colour.base2};
  font-weight: 400;
  border-bottom: 1px solid ${props => props.theme.styles.colour.divider};
`;

const Sidebar = styled.div`
  box-sizing: border-box;
  width: 280px;
  background: #fff;
  border-radius: 6px;
  &span: last-of-type {
    border-bottom: 0px;
  }
`;

const SidebarHeader = styled.div`
  background: #f3f3f3;
  height: 32px;
  line-height: 32px;
  color: ${props => props.theme.styles.colour.base1};
  font-weight: 600;
  padding: 0 8px;
  font-size: 13px;
`;

export default compose(
  withGetSettings,
  withState('switch', 'onSwitch', 'general')
  //   withHandlers({
  //     selectThread: props => link =>
  //       props.history.push(
  //         props.data.comment.context.__typename === 'Community'
  //           ? `/communities/${props.data.comment.context.localId}/thread/${link}`
  //           : `/collections/${props.data.comment.context.localId}/${link}`
  //       )
  //   })
)(Component);
