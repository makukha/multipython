#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail


# versions and statuses

DEB_CHANNEL="$(py info -c | jq -r .base_image.channel)"
DEB_CURRENT="$(py info -c | jq -r .base_image.digest)"
DEB_LATEST=$(curl -s "https://hub.docker.com/v2/namespaces/library/repositories/debian/tags/$DEB_CHANNEL" | jq -r .digest)
DEB_STATUS=$([[ "$DEB_CURRENT" == "$DEB_LATEST" ]] && echo latest || echo changed)

PYENV_CURRENT=$(py info -c | jq -r .pyenv.version)
PYENV_LATEST=$(curl -s https://api.github.com/repos/pyenv/pyenv/releases | jq -r .[0].name | sed -e's/^v//')
PYENV_STATUS=$([[ "$PYENV_CURRENT" == "$PYENV_LATEST" ]] && echo latest || echo changed)

UV_CURRENT=$(py info -c | jq -r .uv.version)
UV_LATEST=$(curl -s https://api.github.com/repos/astral-sh/uv/releases | jq -r .[0].name | sed -e's/^v//')
UV_STATUS=$([[ "$UV_CURRENT" == "$UV_LATEST" ]] && echo latest || echo changed)

# presentation helpers

row () {
  status="$1"
  current="$2"
  latest="$3"
  if [ "$status" == "changed" ]; then
    printf '\033[0;31m%7s  %s\033[0m' "$status" "$latest"
  else
    printf '\033[0;32m%7s  %s\033[0m' "$status" "$current"
  fi
}

# status table

printf "DEBIAN_DIGEST  %s\n" "$(row "$DEB_STATUS" "$DEB_CURRENT" "$DEB_LATEST")"
printf "PYENV_VERSION  %s\n" "$(row "$PYENV_STATUS" "$PYENV_CURRENT" "$PYENV_LATEST")"
printf "UV_VERSION     %s\n" "$(row "$UV_STATUS" "$UV_CURRENT" "$UV_LATEST")"

# pyenv latest hash
if [ "$PYENV_STATUS" == "changed" ]; then
  wget -q "https://github.com/pyenv/pyenv/archive/refs/tags/v${PYENV_LATEST}.tar.gz" -O /tmp/pyenv.tar.gz
  printf "PYENV_SHA256   %s\n" "$(row "$PYENV_STATUS" "?" "$(sha256sum /tmp/pyenv.tar.gz | cut -d' ' -f1)")"
fi

# uv latest hash
if [ "$UV_STATUS" == "changed" ]; then
  wget -q "https://github.com/astral-sh/uv/releases/download/${UV_LATEST}/uv-x86_64-unknown-linux-gnu.tar.gz" -O /tmp/uv.tar.gz
  UV_TAR_SHA256="$(sha256sum /tmp/uv.tar.gz | cut -d' ' -f1)"
  UV_GITHUB_SHA256="$(wget -q -O- "https://github.com/astral-sh/uv/releases/download/${UV_LATEST}/uv-x86_64-unknown-linux-gnu.tar.gz.sha256" | cut -d' ' -f1)"
  if [ ! "$UV_TAR_SHA256" == "$UV_GITHUB_SHA256" ]; then
    printf "uv sha256 do not match!\n" >&2
    exit 1
  fi
  printf "UV_SHA256      %s\n" "$(row "$UV_STATUS" "?" "$UV_GITHUB_SHA256")"
fi

# summary

if [ "$DEB_STATUS $PYENV_STATUS $UV_STATUS" = "latest latest latest" ]; then
  printf "All dependencies are up to date!\n"
  exit 0
else
  printf "Dependencies changed, project update required.\n" >&2
  exit 1
fi
