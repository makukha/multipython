#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail


if [ $# = 0 ]; then
  printf "Option required\n" >&2
  exit 1
fi

PYTHON="$1"

if [ -z "$(command -v "$PYTHON")" ] && [ ! -f "$1" ]; then
  printf "Executable does not exist: %s\n" "$1" >&2
  exit 1
fi


declare -rA PATTERN=(
  ["py314t"]="Python 3.14.0a3 experimental free-threading build ("
  ["py313t"]="Python 3.13.1 experimental free-threading build ("
  ["py314"]="Python 3.14.0a3 ("
  ["py313"]="Python 3.13.1 ("
  ["py312"]="Python 3.12.8 ("
  ["py311"]="Python 3.11.11 ("
  ["py310"]="Python 3.10.16 ("
  ["py39"]="Python 3.9.21 ("
  ["py38"]="Python 3.8.20 ("
  ["py37"]="Python 3.7.17 ("
  ["py36"]="Python 3.6.15 ("
  ["py35"]="Python 3.5.10"
  ["py27"]="Python 2.7.18"
)

HEADER="$("$PYTHON" -VV 2>&1 | head -1)"

for TAG in "${!PATTERN[@]}"; do
  if [[ "$HEADER" == "${PATTERN[$TAG]}"* ]]; then
    echo "$TAG"
    exit 0
  fi
done

printf "Unknown executable: %s\n" "$HEADER" >&2
exit 1
