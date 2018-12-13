#!/bin/sh

release_ctl eval --mfa "MoodleNet.ReleaseTasks.migrate_db/1" --argv -- "$@"
