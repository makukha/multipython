#!/usr/bin/env bash
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
py --help | diff -s - usage.txt
py | diff -s - usage.txt


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


# TEST: py info

echo -e "\n>>> Testing: $SUBSET: py info..."
py info -c | diff -s - "info/$SUBSET.json"
py info | diff -s - "info/$SUBSET.json"


# TEST: py install


echo -e "\n>>> Testing: $SUBSET: py install..."
if [ "$SUBSET" = "base" ]; then
  [ "$(py install 2>&1)" = "No Python distributions found" ]
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
  [ "$(py sys 2>&1)" = "Executable does not exist: python" ]
else
  [ "$(py sys)" = "$(jq -r '.python[] | select(.is_system==true) | .tag' "info/$SUBSET.json")" ]
fi


# TEST: py tag

echo -e "\n>>> Testing: $SUBSET: py tag..."
[ "$(py tag 2>&1)" = "Option required" ]
[ "$(py tag uNdEfInEd 2>&1)" = "Executable does not exist: uNdEfInEd" ]
chmod a+x /tmp/share/unknown.sh
[ "$(py tag /tmp/share/unknown.sh 2>&1)" = "Unknown executable: Python X.Y.Z" ]
if [ "$SUBSET" != "base" ]; then
  py bin --path | xargs -n1 py tag | diff -s - <(py ls --tag)
fi


# TEST: tox

echo -e "\n>>> Testing: $SUBSET: tox..."
if [ "$SUBSET" = "base" ]; then
  true  # no tox installed
elif [ "$SUBSET" = "unsafe" ]; then
  tox run
elif [[ " py27 py35 py36 " == *" $SUBSET "* ]]; then
  tox run -e "$SUBSET" --skip-pkg-install
elif ( tox list | grep -q "^$SUBSET " ); then
  tox run -e "$SUBSET"
else
  tox run -m "$SUBSET" -vvv
fi


# TEST: virtualenv

echo -e "\n>>> Testing: $SUBSET: virtualenv..."
virtualenv --no-seed "/tmp/sys" && [ "$(py tag /tmp/sys/bin/python)" = "$(py sys)" ]
for TAG in $(py ls --tag | xargs)
do
  virtualenv --python "$TAG" --no-seed "/tmp/$TAG"
  [ "$(py tag "/tmp/$TAG/bin/python")" = "$TAG" ]
done


# TESTS BELOW THIS LINE MUST REMAIN IN THE END


# TEST: uninstall

echo -e "\n>>> Testing: $SUBSET: uninstall..."

if [[ "$SUBSET" != "base" ]]; then
  py uninstall
  command -v python && false
  [ "$(py info -c | jq -c .system | xargs)" = "null" ]
  [ "$(py info -c | jq -c .multipython.subset)" = "\"custom\"" ]
fi


# TEST: install --sys

echo -e "\n>>> Testing: $SUBSET: install --sys TAG..."
if [[ "$SUBSET" != "base" ]]; then
  for TAG in $(py ls --tag | xargs)
  do
    py install --sys "$TAG"
    virtualenv --no-seed "/tmp/sys$TAG"
    [ "$(py tag "/tmp/sys$TAG/bin/python")" = "$TAG" ]
    py uninstall
  done
fi
