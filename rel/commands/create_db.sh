#!/bin/sh

release_ctl eval --mfa "MoodleNet.ReleaseTasks.create_db/1" --argv -- "$@"
