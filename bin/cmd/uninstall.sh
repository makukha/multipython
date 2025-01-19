#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail


MULTIPYTHON_ROOT="$(py root)"
# shellcheck disable=SC1091
source "$MULTIPYTHON_ROOT/bin/cmd/.env"

DATA="$(py ls --all)"

if [ ! -e "$MULTIPYTHON_SYSTEM" ]; then
  printf "Multipython system interpreter not installed\n" >&2
  exit 1
fi

# remove symlinks
paste -d' ' <(py bin --cmd) | awk '{system("rm /usr/local/bin/" $1)}'

# remove system environment
rm -rf "$MULTIPYTHON_SYSTEM"

# remove virtualenv configuration
rm "$VIRTUALENV_CONFIG"

# update json info
SUBSET="custom"
echo "$SUBSET" > "$MULTIPYTHON_SUBSET"
py info | tee "$MULTIPYTHON_INFO" | jq
