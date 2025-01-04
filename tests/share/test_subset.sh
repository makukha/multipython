#!/bin/bash
set -eEux -o pipefail


cd /tmp/share
SUBSET="$1"

if [ "$SUBSET" = "base" ]; then
  filter_subset=cat
else
  TAGS="$(jq -r .python[].tag "info/$SUBSET.json" | xargs echo | sed 's/ /|/g; s/\./\\./g')"
  filter_subset () {
    awk '$3 ~ /^('"$TAGS"')$/ {print $0}'
  }
fi


# TEST: py --help

echo -e "\n>>> Testing: $SUBSET: py --help..."
py --help | diff -s - "usage.txt"
py | diff -s - "usage.txt"


# TEST: py --version

echo -e "\n>>> Testing: $SUBSET: py --version..."
py --version | diff -s - <(echo "multipython $(jq -r .multipython.version < info/$SUBSET.json)")


# TEST: py bin

echo -e "\n>>> Testing: $SUBSET: py bin..."

if [ "$SUBSET" = "base" ]; then

  py bin | [ ! -t 0 ]

else

  _py_bin_cmds () {
    paste -d' ' "latest/ls-table.txt" "latest/bin.txt" | filter_subset | awk '{print $4}'
  }
  _py_bin_dirs () {
    paste -d' ' "latest/ls-table.txt" "latest/bin-path.txt" | filter_subset | awk '{print $4}' | sed 's|/python$||'
  }
  _py_bin_paths () {
    paste -d' ' "latest/ls-table.txt" "latest/bin-path.txt" | filter_subset | awk '{print $4}'
  }

  # all versions
  py bin | diff -s - <(_py_bin_cmds)
  py bin --dir | diff -s - <(_py_bin_dirs)
  py bin --path | diff -s - <(_py_bin_paths)

  # single versions
  for variant in --long --short --tag
  do
    py ls "$variant" | xargs -n1 py bin | diff -s - <(_py_bin_cmds)
    py ls "$variant" | xargs -n1 py bin --dir | diff -s -  <(_py_bin_dirs)
    py ls "$variant" | xargs -n1 py bin --path | diff -s - <(_py_bin_paths)
  done

  # invalid version
  py bin 0.0.0 | [ ! -t 0 ]
  py bin --path 0.0.0 | [ ! -t 0 ]
  py bin --dir 0.0.0 | [ ! -t 0 ]

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

  py ls | [ ! -t 0 ]

else

  py ls | diff -s - <(cat "latest/ls-table.txt" | filter_subset | awk '{print $1}')
  py ls --long | diff -s - <(cat "latest/ls-table.txt" | filter_subset | awk '{print $1}')
  py ls --short | diff -s - <(cat "latest/ls-table.txt" | filter_subset | awk '{print $2}')
  py ls --tag | diff -s - <(cat "latest/ls-table.txt" | filter_subset | awk '{print $3}')

fi


# TEST: py root

echo -e "\n>>> Testing: $SUBSET: py root..."
[ "$(py root)" = "/root/.multipython" ]


# TEST: py sys

echo -e "\n>>> Testing: $SUBSET: py sys..."

if [ "$SUBSET" = "base" ]; then

  py sys | [ ! -t 0 ]
  py sys --long | [ ! -t 0 ]
  py sys --short | [ ! -t 0 ]
  py sys --tag | [ ! -t 0 ]
  py sys --table | [ ! -t 0 ]

else

  LONG_SYS="$(jq -r '.python[] | select(.is_system==true) | .version' info/$SUBSET.json)"
  SHORT_SYS="$(jq -r '.python[] | select(.is_system==true) | .short' info/$SUBSET.json)"
  TAG_SYS="$(jq -r '.python[] | select(.is_system==true) | .tag' info/$SUBSET.json)"

  [ "$(py sys)" = "$LONG_SYS" ]
  [ "$(py sys --long)" = "$LONG_SYS" ]
  [ "$(py sys --short)" = "$SHORT_SYS" ]
  [ "$(py sys --tag)" = "$TAG_SYS" ]
  py sys --table | diff -s - <(cat "latest/ls-table.txt" | awk '$3 ~ /^'"$TAG_SYS"'$/ {print $0}')

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
