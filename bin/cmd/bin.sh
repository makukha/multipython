#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail


PYENV_ROOT="$(pyenv root)"

case $1 in
  -c|--cmd) OPTION=--cmd; shift ;;
  -d|--dir) OPTION=--dir; shift ;;
  -p|--path) OPTION=--path; shift ;;
  *)
    printf "Unknown option: %s\n" "$1" >&2
    exit 1
    ;;
esac

getprop () {
  case $OPTION in
    --cmd)  awk '{print "python"$2}' ;;
    --dir)  awk '{print "'"$PYENV_ROOT/versions/"'"$3"/bin"}' ;;
    --path) awk '{print "'"$PYENV_ROOT/versions/"'"$3"/bin/python"}' ;;
  esac
}

TAG="${1:-}"

filter () {
  if [ "$TAG" = "" ]; then
    cat
  else
    sed -n '/^'"$TAG"' /p'
  fi
}

py ls --all | filter | getprop
