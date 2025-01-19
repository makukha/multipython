#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail


MULTIPYTHON_ROOT="$(py root)"
# shellcheck disable=SC1091
source "$MULTIPYTHON_ROOT/bin/cmd/.env"

if [ -e "$MULTIPYTHON_SYSTEM" ]; then
  printf "Multipython system interpreter already installed\n" >&2
  exit 1
fi

SUBSET="custom"
TAG=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --as) SUBSET="$2"; shift; shift ;;  # this option is for internal use
    --tag) TAG="$2"; shift; shift ;;
    *)
      printf "Unknown option: %S" "$1" >&2
      exit 1
      ;;
  esac
done

DATA="$(py ls --all)"

propose_sys_tag () {
  LONG="$(awk '{print $3}' <<<"$DATA")"
  # first, try stable Python w/o free threading
  VER="$(sed '/[0-9]\(a\|b\|rc\)/d; /t$/d' <<<"$LONG" | head -1)"
  if [ -z "$VER" ]; then
    # second, try latest Python w/o free threading
    VER="$(sed '/t$/d' <<<"$LONG" | head -1)"
    if [ -z "$VER" ]; then
      # third, use whatever latest Python
      VER="$(head -1 <<<"$LONG")"
    fi
  fi
  awk '$3 ~ /^('"$VER"')$/ {print $1}' <<<"$DATA"
}

pip_install () {
  PYTHON="$1"
  shift
  case "$(py tag "$PYTHON")" in
    py27) ARGS="--no-cache-dir" ;;
    py35) ARGS="--no-cache-dir --cert=/etc/ssl/certs/ca-certificates.crt" ;;
    py36) ARGS="--no-cache-dir" ;;
    *)    ARGS="--no-cache-dir --root-user-action=ignore" ;;
  esac
  # shellcheck disable=SC2086
  "$PYTHON" -m pip install $ARGS "$@"
}

pip_seed_bindir () {
  BINDIR="$1"
  SEEDFLAG="$BINDIR/.multipython"

  if [ ! -e "$SEEDFLAG" ]; then
    pip_install "$BINDIR/python" -U pip setuptools
    touch "$SEEDFLAG"
  fi
}

virtualenv_spec () {
  MIN="$(awk '{print $2}' <<<"$DATA" | sed 's/^[^0-9]\+//' | sort -V | head -1)"
  if [ "$MIN" = "$(echo -e "3.6\n$MIN" | sort -V | head -1)" ]; then
    echo "virtualenv>=20,<20.22"  # MIN<=3.6
  elif [ "$MIN" = "3.7" ]; then
    echo "virtualenv>=20,<20.27"
  else
    echo "virtualenv>=20"
  fi
}

pip_install_system () {
  if [ -z "$TAG" ]; then
    TAG="$(propose_sys_tag)"
  fi
  BINDIR="$(py bin --dir "$TAG")"

  # install virtualenv in sys tag, create sys venv, remove virtualenv
  ORIGINAL="$("$BINDIR/python" -m pip freeze --all)"
  pip_install "$BINDIR/python" virtualenv
  "$BINDIR/python" -m virtualenv --discovery=builtin "$MULTIPYTHON_SYSTEM"
  "$BINDIR/python" -m pip freeze | sed 's/==.*//' | xargs "$BINDIR/python" -m pip uninstall -y
  echo "$ORIGINAL" | xargs "$BINDIR/python" -m pip install

  # seed system environment
  pip_seed_bindir "$MULTIPYTHON_SYSTEM/bin"

  PYTHON="$MULTIPYTHON_SYSTEM/bin/python"

  # install tox, virtualenv, and plugins
  pip_install "$PYTHON" tox "$(virtualenv_spec)" "virtualenv-multipython==$MULTIPYTHON_PLUGIN_VIRTUALENV_VER"
  if [ "$("$PYTHON" -m tox -q --version 2>/dev/null | cut -c1)" = "3" ]; then
    pip_install "$PYTHON" "tox-multipython==$MULTIPYTHON_PLUGIN_TOX_VER"
  fi

  # configure virtualenv
  mkdir -p "$(dirname "$VIRTUALENV_CONFIG")"
  printf "[virtualenv]\ndiscovery = multipython\n" > "$VIRTUALENV_CONFIG"
}


if [ "$SUBSET" != "base" ]; then

  if [ -z "$DATA" ]; then
    printf "No Python distributions found\n" >&2
    exit 1
  fi

  # symlink commands
  paste -d' ' <(py bin --path) <(py bin --cmd) | awk '{system("ln -s " $1 " /usr/local/bin/" $2)}'

  # seed tags
  py bin --dir | while read -r BINDIR; do
    pip_seed_bindir "$BINDIR"
  done

  # provision system environment
  pip_install_system

fi

# set installed subset name
echo "$SUBSET" > "$MULTIPYTHON_SUBSET"

# generate and validate versions info
py info | tee "$MULTIPYTHON_INFO" | jq
