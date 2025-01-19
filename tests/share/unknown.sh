#!/usr/bin/env bash

if [ $# = 1 ] && [ "$1" = "-VV" ]; then
  echo "Python X.Y.Z" >&2
else
  exit 1
fi
