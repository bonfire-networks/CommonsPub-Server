#!/bin/sh

release_ctl eval --mfa "MoodleNet.ReleaseTasks.drop_db/1" --argv -- "$@"
