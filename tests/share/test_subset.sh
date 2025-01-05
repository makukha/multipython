#!/bin/bash
# shellcheck disable=SC2266
set -eEux -o pipefail


cd /tmp/share
SUBSET="$1"

if [ "$SUBSET" = "base" ]; then
  # shellcheck disable=SC2034
  filter_subset="cat"
else
  TAGS="$(jq -r .python[].tag "info/$SUBSET.json" | xargs echo | sed 's/ /|/g; s/\./\\./g')"
  filter_subset () {
    awk '$1 ~ /^('"$TAGS"')$/ {print $0}'
  }
fi


# TEST: py --help

echo -e "\n>>> Testing: $SUBSET: py --help..."
py --help | diff -s - "usage.txt"
py | diff -s - "usage.txt"


# TEST: py --version

echo -e "\n>>> Testing: $SUBSET: py --version..."
py --version | diff -s - <(echo "multipython $(jq -r .multipython.version < "info/$SUBSET.json")")


# TEST: py bin

echo -e "\n>>> Testing: $SUBSET: py bin..."
if [ "$SUBSET" = "base" ]; then
  py bin --cmd | [ ! -t 0 ]
  py bin --path | [ ! -t 0 ]
  py bin --dir | [ ! -t 0 ]
  py bin && exit 1
else
  _py_bin_cmds () {
    paste -d' ' "data/ls.txt" "data/bin.txt" | filter_subset | awk '{print $5}'
  }
  _py_bin_paths () {
    paste -d' ' "data/ls.txt" "data/bin.txt" | filter_subset | awk '{print $6}'
  }
  _py_bin_dirs () {
    _py_bin_paths | sed 's|/python$||'
  }
  # all versions
  py bin --cmd | diff -s - <(_py_bin_cmds)
  py bin --dir | diff -s - <(_py_bin_dirs)
  py bin --path | diff -s - <(_py_bin_paths)
  # single versions
  py ls --tag | xargs -n1 py bin --cmd | diff -s - <(_py_bin_cmds)
  py ls --tag | xargs -n1 py bin --dir | diff -s -  <(_py_bin_dirs)
  py ls --tag | xargs -n1 py bin --path | diff -s - <(_py_bin_paths)
  # invalid version
  py bin --cmd 0.0.0 | [ ! -t 0 ]
  py bin --path 0.0.0 | [ ! -t 0 ]
  py bin --dir 0.0.0 | [ ! -t 0 ]
  # option required
  py bin && exit 1
fi


# TEST: py checkupd

echo -e "\n>>> Testing: $SUBSET: py checkupd..."
py checkupd


# TEST: py info

echo -e "\n>>> Testing: $SUBSET: py info..."
py info -c | diff -s - "info/$SUBSET.json"
py info | diff -s - "info/$SUBSET.json"


# TEST: py install


echo -e "\n>>> Testing: $SUBSET: py install..."
if [ "$SUBSET" = "base" ]; then
  [ "$(py install 2>&1)" = "No Python distributions found." ]
else
  # "py install" is tested by "py info"
  true
fi


# TEST: py ls

echo -e "\n>>> Testing: $SUBSET: py ls..."
if [ "$SUBSET" = "base" ]; then
  py ls --long | [ ! -t 0 ]
  py ls --short | [ ! -t 0 ]
  py ls --tag | [ ! -t 0 ]
  py ls --all | [ ! -t 0 ]
  py ls && exit 1
else
  py ls --long | diff -s - <(filter_subset < data/ls.txt | awk '{print $3}')
  py ls --short | diff -s - <(filter_subset < data/ls.txt | awk '{print $2}')
  py ls --tag | diff -s - <(filter_subset < data/ls.txt | awk '{print $1}')
  py ls --all | diff -s - <(filter_subset < data/ls.txt)
  # option required
  py ls && exit 1
fi


# TEST: py root

echo -e "\n>>> Testing: $SUBSET: py root..."
[ "$(py root)" = "/root/.multipython" ]


# TEST: py sys

echo -e "\n>>> Testing: $SUBSET: py sys..."
if [ "$SUBSET" = "base" ]; then
  py sys | [ ! -t 0 ]
else
  [ "$(py sys)" = "$(jq -r '.python[] | select(.is_system==true) | .tag' "info/$SUBSET.json")" ]
fi


# TEST: tox

echo -e "\n>>> Testing: $SUBSET: tox..."
if [ "$SUBSET" = "base" ]; then
  true  # no tox installed
elif [ "$SUBSET" = "latest" ]; then
  tox run
else
  tox run -m "$SUBSET"
fi
