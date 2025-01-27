#!/usr/bin/env sh

cat <<EOF | xargs sudo port install
  go-task
  hadolint
  jq
  shellcheck
  trivy
  uv
  yq
EOF

cat <<EOF | xargs -n1 uv tool install -U
  git+https://github.com/makukha/bump-my-version@date62
  caseutil
  docsub
  mypy
  ruff
  towncrier
EOF
