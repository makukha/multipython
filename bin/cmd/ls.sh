#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail


if [ $# = 0 ]; then
  printf "Option required\n" >&2
  exit 1
fi

PYENV_ROOT="$(pyenv root)"

ls_long () {
  if [ -d "$PYENV_ROOT/versions" ]; then
    # shellcheck disable=SC2012
    ls -1 "$PYENV_ROOT/versions" | sed 's/\(.*t\)$/t\1/' | sort -rV | sed 's/^t//'
  fi
}

long_to_short () {
  sed 's/^\([0-9]*\)\.\([0-9]*\)[^t]*\(t\?\)$/\1.\2\3/'
}

short_to_tag () {
  sed 's/^/py/; s/\.//'
}

ls_all () {
  ls_long | while IFS= read -r LONG
  do
    SHORT="$(long_to_short <<<"$LONG")"
    TAG="$(short_to_tag <<<"$SHORT")"
    printf "%s %s %s\n" "$TAG" "$SHORT" "$LONG"
  done
}

case $1 in
  -l|--long) ls_long ;;
  -s|--short) ls_long | long_to_short ;;
  -t|--tag) ls_long | long_to_short | short_to_tag ;;
  -a|--all) ls_all ;;
  *)
    printf "Unknown option: %S" "$1" >&2
    exit 1
    ;;
esac
