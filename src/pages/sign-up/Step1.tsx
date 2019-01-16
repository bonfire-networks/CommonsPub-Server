import * as React from 'react';
import { TextField, Label } from '@zendeskgarden/react-textfields';
import { Col, Row } from '@zendeskgarden/react-grid';

import { Trans } from '@lingui/macro';
import { i18nMark } from '@lingui/react';

const tt = {
  placeholders: {
    email: i18nMark('e.g. mary@moodlers.org'),
    password: i18nMark('Choose a password'),
    name: i18nMark('e.g. Moodler Mary'),
    bio: i18nMark('Introduce yourself to the community...'),
    location: i18nMark('e.g. United Kingdom')
  }
};

import H6 from '../../components/typography/H6/H6';
import P from '../../components/typography/P/P';
import TextInput from '../../components/inputs/Text/Text';
import TextArea from '../../components/inputs/TextArea/Textarea';
import Button from '../../components/elements/Button/Button';
import LanguageSelect from '../../components/inputs/LanguageSelect/LanguageSelect';
import styled from '../../themes/styled';

const Spacer = styled.div`
  height: 10px;
  width: 100%;
`;

const OverflowCol = styled(Col)`
  overflow: auto;
`;

export default ({ user, randomizeEmojiId, linkUserState }) => {
  return (
    <>
      <Row>
        <OverflowCol>
          <H6 style={{ borderBottom: '1px solid lightgrey' }}>
            <span style={{ color: 'darkgrey', fontSize: '.6em' }}>1.</span>{' '}
            <Trans>Account</Trans>
          </H6>
          <P>
            <Trans>This data will never be shared.</Trans>
          </P>
          <TextField>
            <Label>
              <Trans>Email address</Trans>
            </Label>
            <TextInput
              value={user.email}
              onChange={linkUserState('email')}
              placeholder={tt.placeholders.email}
              maxLength={100}
            />
          </TextField>
          <Spacer />
          <TextField>
            <Label>
              <Trans>Password</Trans>
            </Label>
            <TextInput
              value={user.password}
              onChange={linkUserState('password')}
              placeholder={tt.placeholders.password}
              type="password"
            />
          </TextField>
          <Spacer />
          <H6 style={{ borderBottom: '1px solid lightgrey' }}>
            <span style={{ color: 'darkgrey', fontSize: '.6em' }}>2.</span>{' '}
            <Trans>Profile</Trans>
          </H6>
          <P>
            <Trans>This information will appear on your public profile.</Trans>
          </P>
          <TextField>
            <Label>
              <Trans>Emoji ID</Trans>
            </Label>
            <TextInput
              disabled
              style={{ backgroundColor: 'white' }}
              value={user.preferredUsername}
              button={
                <Button onClick={randomizeEmojiId}>
                  <Trans>Shuffle</Trans>
                </Button>
              }
            />
          </TextField>
          <Spacer />

          <TextField>
            <Label>
              <Trans>Name</Trans>
            </Label>
            <TextInput
              value={user.name}
              onChange={linkUserState('name')}
              placeholder={tt.placeholders.name}
              maxLength={20}
            />
          </TextField>
          <Spacer />
          <TextField>
            <Label>
              <Trans>Bio</Trans>
            </Label>
            <TextArea
              value={user.bio}
              onChange={linkUserState('bio')}
              placeholder={tt.placeholders.bio}
              maxLength={250}
            />
          </TextField>
          <Spacer />
          <TextField>
            <Label>
              <Trans>Language</Trans>
            </Label>
            <LanguageSelect fullWidth={true} />
          </TextField>
          <Spacer />
          <TextField>
            <Label>
              <Trans>Location</Trans>
            </Label>
            <TextInput
              value={user.location}
              onChange={linkUserState('location')}
              placeholder={tt.placeholders.location}
              maxLength={50}
            />
          </TextField>
          {/*<Spacer />*/}
          {/*<TextField>*/}
          {/*<Label>Role</Label>*/}
          {/*<TextInput*/}
          {/*value={user.role}*/}
          {/*onChange={linkUserState('role')}*/}
          {/*placeholder="e.g. Head Teacher"*/}
          {/*maxLength={50}*/}
          {/*/>*/}
          {/*</TextField>*/}
        </OverflowCol>
      </Row>
    </>
  );
};
