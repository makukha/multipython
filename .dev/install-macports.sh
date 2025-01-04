#!/usr/bin/env sh

sudo port install go-task jq uv yq

uv tool install bump-my-version
uv tool install docsub
uv tool install towncrier
