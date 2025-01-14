#!/usr/bin/env sh

sudo port install go-task hadolint jq shellcheck uv yq

uv tool install -U git+https://github.com/makukha/bump-my-version@date62
uv tool install -U caseutil
uv tool install -U docsub
uv tool install -U towncrier
