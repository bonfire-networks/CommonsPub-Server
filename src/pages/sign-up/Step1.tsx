import * as React from 'react';
import { TextField, Label } from '@zendeskgarden/react-textfields';
import { Col, Row } from '@zendeskgarden/react-grid';

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
            Personal details
          </H6>
          <P>
            What your profile will look like is on the right. Start entering the
            details below to build it.
          </P>
          <TextField>
            <Label>Name</Label>
            <TextInput
              value={user.name}
              onChange={linkUserState('name')}
              placeholder="e.g. Moodler Joe"
              maxLength={20}
            />
          </TextField>
          <Spacer />
          <TextField>
            <Label>Password</Label>
            <TextInput
              value={user.password}
              onChange={linkUserState('password')}
              placeholder="Enter a password"
              type="password"
            />
          </TextField>
          <Spacer />
          <TextField>
            <Label>Emoji ID</Label>
            <TextInput
              disabled
              style={{ backgroundColor: 'white' }}
              value={user.preferredUsername}
              button={<Button onClick={randomizeEmojiId}>Shuffle</Button>}
            />
          </TextField>
          <Spacer />
          <TextField>
            <Label>Email address</Label>
            <TextInput
              value={user.email}
              onChange={linkUserState('email')}
              placeholder="e.g. joe@moodle.net"
              maxLength={100}
            />
          </TextField>
          <Spacer />
          <TextField>
            <Label>Bio</Label>
            <TextArea
              value={user.bio}
              onChange={linkUserState('bio')}
              placeholder="Tell us a bit about yourself"
              maxLength={250}
            />
          </TextField>
          <Spacer />
          <TextField>
            <Label>Language</Label>
            <LanguageSelect fullWidth={true} />
          </TextField>
          <Spacer />
          <TextField>
            <Label>Location</Label>
            <TextInput
              value={user.location}
              onChange={linkUserState('location')}
              placeholder="e.g. United Kingdom"
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
