#! /bin/bash

. /root/.multipython

IMAGE_CURRENT="$MULTIPYTHON_BASE_IMAGE_DIGEST"
IMAGE_LATEST=$(curl -s https://hub.docker.com/v2/namespaces/library/repositories/debian/tags/stable-slim | jq -r .digest)
IMAGE_STATUS=$([[ "$IMAGE_CURRENT" == "$IMAGE_LATEST" ]] && echo latest || echo changed)

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

printf "IMAGE_DIGEST   %s\n" "$(row "$IMAGE_STATUS" "$IMAGE_CURRENT" "$IMAGE_LATEST")"
printf "PYENV_VERSION  %s\n" "$(row "$PYENV_STATUS" "$PYENV_CURRENT" "$PYENV_LATEST")"

if [ "$PYENV_STATUS" == "changed" ]; then
wget -q https://github.com/pyenv/pyenv/archive/refs/tags/v${PYENV_VERSION}.tar.gz -O /tmp/pyenv.tar.gz
printf "PYENV_SHA256   %s\n" "$(row "$PYENV_STATUS" "?" "$(sha256sum /tmp/pyenv.tar.gz | cut -d' ' -f1)")"
fi

if [ "$IMAGE_STATUS $PYENV_STATUS" = "latest latest" ]; then
  echo "All dependencies are up to date!"
  exit 0
else
  echo "Dependencies changed, update required."
  exit 1
fi
