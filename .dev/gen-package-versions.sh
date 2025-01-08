#!/usr/bin/env bash

IMG=makukha/multipython

RELEASE="$1"
SUBSET="latest cpython supported unsafe"
PARTIAL="py314t py313t py314 py313 py312 py311 py310 py39 py38 py37 py36 py35 py27"
PKG=(pip setuptools tox virtualenv)


mkdir -p tmp/info

# get LATEST version numbers
LATEST=()
docker run --rm "$IMG:cpython-$RELEASE" py info -c > tmp/info/cpython.json
for (( i = 0; i < ${#PKG[@]}; i++ ))
do
  LATEST+=("$(jq -r '.python[] | select(.is_system==true) | .packages.'"${PKG[$i]}" "tmp/info/cpython.json")")
done

print_rows () {
  for tag in $1
  do
    # copy json metadata
    if [ "$tag" = "latest" ]; then
      docker run --rm "$IMG:$RELEASE" py info -c > "tmp/info/$tag.json"
    elif [ "$tag" = "cpython" ]; then
      true  # already copied
    else
      docker run --rm "$IMG:$tag-$RELEASE" py info -c > "tmp/info/$tag.json"
    fi
    # output rows
    echo -n "| "'`'"$tag"'`'" "
    for (( i = 0; i < ${#PKG[@]}; i++ ))
    do
      V="$(jq -r ".python[] | select(.is_system==true) | .packages.${PKG[$i]}" "tmp/info/$tag.json")"
      echo -n "| $V"
      if [ "$V" = "${LATEST[$i]}" ]; then printf ' \xE2\x9C\xA8 '; else printf ' '; fi
    done
    echo "|"
    echo -n '.' 1>&2  # progress
  done
  echo 1>&2  # progress
}

# body: subsets
print_rows "$SUBSET"

# body: base
echo -n "| "'`'"base"'`'" "
for col in "${PKG[@]}"; do echo -n "| — "; done; echo "|"

# body: partial
print_rows "$PARTIAL"
