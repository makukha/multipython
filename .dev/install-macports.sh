#!/usr/bin/env sh

sudo port install go-task jq uv yq

uv tool install git+https://github.com/makukha/bump-my-version@date62
uv tool install docsub
uv tool install towncrier
