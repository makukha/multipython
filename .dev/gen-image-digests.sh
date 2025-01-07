#!/usr/bin/env bash

IMG=makukha/multipython
TAGS_URL=https://hub.docker.com/v2/namespaces/makukha/repositories/multipython/tags

RELEASE="$1"
if [ $# = 0 ]; then
  echo "Release required" >&2
  exit 1
fi

print_rows () {
  while IFS= read -r TAG
  do
    DIGEST="$(curl -s "$TAGS_URL/$TAG" | jq -r .digest)"
    printf '%s %s\n' "$TAG" "$DIGEST"
    printf '.' >&2
  done
  printf '\n' >&2
}

docker buildx bake --print 2>/dev/null \
  | jq -r '.target[] | .tags[]' \
  | sed -n "/-$RELEASE$/p" \
  | sort \
  | cut -d: -f2 \
  | print_rows
