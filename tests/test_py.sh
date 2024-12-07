#!/bin/bash

set -eux -o pipefail

PYMIN_LONG=$1
PYSYS_LONG=$2
PYMAX_LONG=$3


# --- define values

get () {
  N=$(xargs -n1 < files/dist-long.txt | grep -nw "$2" | cut -d: -f1)
  sed -n "$N p" < "files/dist-$1.txt"
}

PYMIN_SHORT=$(get short "${PYMIN_LONG}")
PYMIN_NODOT=$(get nodot "${PYMIN_LONG}")

PYSYS_SHORT=$(get short "${PYSYS_LONG}")
PYSYS_NODOT=$(get nodot "${PYSYS_LONG}")
PYSYS_TAG=$(get tag "${PYSYS_LONG}")

PYMAX_SHORT=$(get short "${PYMAX_LONG}")
PYMAX_NODOT=$(get nodot "${PYMAX_LONG}")


# --- run tests

py --help | diff files/usage.txt -
py | diff files/usage.txt -

# binary

test "$(py binary --name "${PYSYS_TAG}")" == "python${PYSYS_SHORT}"
test "$(py binary --path "${PYSYS_TAG}")" == "/root/.pyenv/versions/${PYSYS_LONG}/bin/python"

# install

test "$(py version --sys --nodot)" == "${PYSYS_NODOT}"
test "$(which python)" == "$(py root)/sys/python"
test "$(which pip)" == "$(py root)/sys/pip"
tox -q --version
for v in $(py ls --short); do
  if [ "$v" = "${PYSYS_SHORT}" ]; then
    test "$(which "python$v")" == "$(py root)/sys/python$v"
  else
    test "$(which "python$v")" == "/usr/local/bin/python$v"
  fi
done

# list

py ls | diff files/dist-long.txt -
py ls --long | diff files/dist-long.txt -
py ls --short | diff files/dist-short.txt -
py ls --nodot | diff files/dist-nodot.txt -
py ls --tag | diff files/dist-tag.txt -

py ls | diff files/dist-long.txt -
py ls --long | diff files/dist-long.txt -
py ls --short | diff files/dist-short.txt -
py ls --nodot | diff files/dist-nodot.txt -
py ls --tag | diff files/dist-tag.txt -

# root

test "$(py root)" = "/root/.multipython"

# version

test "$(py version --min)" == "${PYMIN_LONG}"
test "$(py version --min --long)" == "${PYMIN_LONG}"
test "$(py version --min --short)" == "${PYMIN_SHORT}"
test "$(py version --min --nodot)" == "${PYMIN_NODOT}"

test "$(py version --max)" == "${PYMAX_LONG}"
test "$(py version --max --long)" == "${PYMAX_LONG}"
test "$(py version --max --short)" == "${PYMAX_SHORT}"
test "$(py version --max --nodot)" == "${PYMAX_NODOT}"

test "$(py version --stable)" == "${PYSYS_LONG}"
test "$(py version --stable --long)" == "${PYSYS_LONG}"
test "$(py version --stable --short)" == "${PYSYS_SHORT}"
test "$(py version --stable --nodot)" == "${PYSYS_NODOT}"

test "$(py version --sys)" == "$(py version --stable)"
test "$(py version --sys --long)" == "$(py version --stable --long)"
test "$(py version --sys --short)" == "$(py version --stable --short)"
test "$(py version --sys --nodot)" == "$(py version --stable --nodot)"
