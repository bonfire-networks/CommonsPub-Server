#!/bin/sh

release_ctl eval --mfa "MoodleNet.ReleaseTasks.seed_db/1" --argv -- "$@"
