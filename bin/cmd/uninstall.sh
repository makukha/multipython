#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail


MULTIPYTHON_ROOT="$(py root)"
# shellcheck disable=SC1091
source "$MULTIPYTHON_ROOT/bin/cmd/.env"

if [ ! -e "$MULTIPYTHON_SYSTEM" ]; then
  printf "Multipython system interpreter not installed\n" >&2
  exit 1
fi

UPDATE_INFO=true

while [[ $# -gt 0 ]]; do
  case $1 in
    --no-update-info) UPDATE_INFO=; shift ;;
    *)
      printf "Unknown option: %s" "$1" >&2
      exit 1
      ;;
  esac
done

# remove symlinks
paste -d' ' <(py bin --cmd) | awk '{system("rm /usr/local/bin/" $1)}'

# remove system environment
rm -rf "$MULTIPYTHON_SYSTEM"

# remove virtualenv configuration
rm "$VIRTUALENV_CONFIG"

# clear installed subset name
SUBSET="custom"

# update json info
echo "$SUBSET" > "$MULTIPYTHON_SUBSET"
if [ "$UPDATE_INFO" = "true" ]; then
  py info | tee "$MULTIPYTHON_INFO" | jq
else
  touch "$MULTIPYTHON_INFO"
fi
