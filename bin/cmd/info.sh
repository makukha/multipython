#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail


MULTIPYTHON_ROOT="$(py root)"
# shellcheck disable=SC1091
source "$MULTIPYTHON_ROOT/bin/cmd/.env"

if [ $# -gt 0 ]; then
  case $1 in
    -c|--cached)
      cat "$MULTIPYTHON_INFO"
      exit 0
      ;;
    *)
      printf "Unknown option: %s" "$1" >&2
      exit 1
      ;;
  esac
fi


if [ -n "$(command -v python)" ]; then
  SYS_TAG="$(py sys)"
else
  SYS_TAG=
fi

python_packages () {
  INDENT="$1"
  PYTHON="$2"
  "$PYTHON" -m pip freeze --all 2>/dev/null | sed 's/^/'"$INDENT"'"/; s/==/": "/; s/$/"/; $! s/$/,/'
}

python_info () {
  TAG="$1"
  SHORT="$2"
  LONG="$3"
  PYTHON_BINARY=$(py bin --path "$TAG")
  printf '    {\n'
  printf '      "version": "%s",\n' "$LONG"
  printf '      "source": "pyenv",\n'
  printf '      "tag": "%s",\n' "$TAG"
  printf '      "short": "%s",\n' "$SHORT"
  printf '      "command": "%s",\n' "$(py bin --cmd "$TAG")"
  printf '      "bin_dir": "%s",\n' "$(py bin --dir "$TAG")"
  printf '      "binary_path": "%s",\n' "$PYTHON_BINARY"
  printf '      "is_system": '%s',\n' "$([ "$TAG" = "$SYS_TAG" ] && echo true || echo false)"
  printf '      "packages": {\n'
  python_packages '        ' "$PYTHON_BINARY"
  printf '      }\n'
  printf '    }'  # no newline here!
}

PYENV_VER="$(pyenv --version 2>/dev/null | cut -d' ' -f2)"
PYENV_ROOT="$(pyenv root)"

if [ -n "$(command -v tox)" ]; then
  TOX_VER="$(tox -q --version 2>/dev/null | head -1 | cut -d' ' -f1)"
else
  TOX_VER=
fi

UV_VER="$(uv --version 2>/dev/null | cut -d' ' -f2)"
UV_ROOT="$(uv python dir)"

if [ -n "$(command -v virtualenv)" ]; then
  VIRTUALENV_VER="$(virtualenv --version 2>&1 | cut -d' ' -f2)"
else
  VIRTUALENV_VER=
fi

printf '{\n'
printf '  "multipython": {\n'
printf '    "version": "%s",\n' "$(cat "$MULTIPYTHON_VERSION")"
printf '    "subset": "%s",\n' "$(cat "$MULTIPYTHON_SUBSET")"
printf '    "root": "%s"\n' "$MULTIPYTHON_ROOT"
printf '  },\n'
if [ -n "$PYENV_VER" ]; then
  printf '  "pyenv": {\n'
  printf '    "version": "%s",\n' "$PYENV_VER"
  printf '    "root": "%s",\n' "$PYENV_ROOT"
  printf '    "python_versions": "%s"\n' "$PYENV_ROOT/versions"
  printf '  },\n'
fi
if [ -n "$TOX_VER" ]; then
  printf '  "tox": {\n'
  printf '    "version": "%s"\n' "$TOX_VER"
  printf '  },\n'
fi
if [ -n "$UV_VER" ]; then
  printf '  "uv": {\n'
  printf '    "version": "%s",\n' "$UV_VER"
  printf '    "python_versions": "%s"\n' "$UV_ROOT"
  printf '  },\n'
fi
if [ -n "$VIRTUALENV_VER" ]; then
  printf '  "virtualenv": {\n'
  printf '    "version": "%s"' "$VIRTUALENV_VER"
  if [ -f "$VIRTUALENV_CONFIG" ]; then
    printf ',\n'
    printf '    "config": "%s"' "$VIRTUALENV_CONFIG"
  fi
  printf '\n  },\n'
fi
if [ -e "$MULTIPYTHON_SYSTEM" ]; then
  printf '  "system": {\n'
  printf '    "tag": "%s",\n' "$(py sys)"
  printf '    "root": "%s",\n' "$MULTIPYTHON_SYSTEM"
  printf '    "command": "python",\n'
  printf '    "bin_dir": "%s",\n' "$MULTIPYTHON_SYSTEM/bin"
  printf '    "binary_path": "%s",\n' "$MULTIPYTHON_SYSTEM/bin/python"
  printf '    "packages": {\n'
  python_packages '      ' "$MULTIPYTHON_SYSTEM/bin/python"
  printf '    }\n'
  printf '  },\n'
fi
printf '  "base_image": {\n'
printf '    "name": "debian",\n'
printf '    "channel": "stable-slim",\n'
printf '    "digest": "%s"\n' "$(cat "$MULTIPYTHON_IMAGE")"
printf '  }'

DATA="$(py ls --all)"

if [ -n "$DATA" ]; then
  printf ',\n  "python": [\n'
  readarray -t ROWS <<<"$DATA"
  for (( i=0; i<${#ROWS[@]}; i++ )); do
    if [ $i -gt 0 ]; then
      printf ',\n'
    fi
    # shellcheck disable=SC2086
    python_info ${ROWS[$i]}
  done
  printf '\n  ]'
fi

printf '\n}\n'
