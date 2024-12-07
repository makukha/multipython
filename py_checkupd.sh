#!/bin/bash

# shellcheck disable=SC1091
. "$(py root)/deps"

DEBIAN_CURRENT="$DEBIAN_DIGEST"
DEBIAN_LATEST=$(curl -s https://hub.docker.com/v2/namespaces/library/repositories/debian/tags/stable-slim | jq -r .digest)
DEBIAN_STATUS=$([[ "$DEBIAN_CURRENT" == "$DEBIAN_LATEST" ]] && echo latest || echo changed)

PYENV_CURRENT=$(pyenv --version | cut -d' ' -f2)
PYENV_LATEST=$(curl -s https://api.github.com/repos/pyenv/pyenv/releases | jq -r .[0].name | sed -e's/^v//')
PYENV_STATUS=$([[ "$PYENV_CURRENT" == "$PYENV_LATEST" ]] && echo latest || echo changed)

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
OFF=$(tput setaf 9)

row () {
  status="$1"
  current="$2"
  latest="$3"
  if [ "$status" == "changed" ]; then
    printf "$RED%7s  %s$OFF" "$status" "$latest"
  else
    printf "$GREEN%7s  %s$OFF" "$status" "$current"
  fi
}

printf "DEBIAN_DIGEST  %s\n" "$(row "$DEBIAN_STATUS" "$DEBIAN_CURRENT" "$DEBIAN_LATEST")"
printf "PYENV_VERSION  %s\n" "$(row "$PYENV_STATUS" "$PYENV_CURRENT" "$PYENV_LATEST")"

if [ "$PYENV_STATUS" == "changed" ]; then
wget -q "https://github.com/pyenv/pyenv/archive/refs/tags/v${PYENV_LATEST}.tar.gz" -O /tmp/pyenv.tar.gz
printf "PYENV_SHA256   %s\n" "$(row "$PYENV_STATUS" "?" "$(sha256sum /tmp/pyenv.tar.gz | cut -d' ' -f1)")"
fi

if [ "$DEBIAN_STATUS $PYENV_STATUS" = "latest latest" ]; then
  echo "All dependencies are up to date!"
  exit 0
else
  echo "Dependencies changed, project update required."
  echo 'Run "pyenv install --list" to get latest Python versions.'
  exit 1
fi
