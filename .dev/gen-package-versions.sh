#!/usr/bin/env bash

IMG=makukha/multipython

SUBSET="latest stable supported"
PARTIAL="py314t py313t py314 py313 py312 py311 py310 py39 py38 py37 py36 py35 py27"
PKG=(pip setuptools tox virtualenv)


mkdir -p tmp/info

# get latest versions
LATEST=()
docker run --rm $IMG:stable py info -c > tmp/info/stable.json
for (( i = 0; i < ${#PKG[@]}; i++ ))
do
  LATEST+=("$(jq -r '.python[] | select(.is_system==true) | .packages.'"${PKG[$i]}" "tmp/info/stable.json")")
done

# header
for col in Tag ${PKG[@]}; do echo -n "| $col "; done; echo "|"
for col in Tag ${PKG[@]}; do echo -n "|---"; done; echo "|"

print_rows () {
  read -ar TAGS <<<"$1"
  for tag in "${TAGS[@]}"
  do
    if [ "$tag" != "stable" ]; then
      docker run --rm "$IMG:$tag" py info -c > "tmp/info/$tag.json"
    fi
    echo -n "| "'`'"$tag"'`'" "
    for (( i = 0; i < ${#PKG[@]}; i++ ))
    do
      V="$(jq -r ".python[] | select(.is_system==true) | .packages.${PKG[$i]}" "tmp/info/$tag.json")"
      echo "| $V"
      if [ "$V" = "${LATEST[$i]}" ]; then printf ' \xE2\x9C\xA8 '; else printf ' '; fi
    done
    echo "|"
  done
}

# body: subsets
print_rows "$SUBSET"

# body: base
echo -n "| "'`'"base"'`'" "
for col in "${PKG[@]}"; do echo -n "| — "; done; echo "|"

# body: partial
print_rows "$PARTIAL"
