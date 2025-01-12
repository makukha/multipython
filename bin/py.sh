#!/bin/bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

MULTIPYTHON_VERSION=2517
VIRTUALENV_MULTIPYTHON_VERSION=0.3.1
TOX_MULTIPYTHON_VERSION=0.2.0

MULTIPYTHON_ROOT=/root/.multipython
MULTIPYTHON_BASE_IMAGE_DIGEST="$MULTIPYTHON_ROOT/base_image_digest"
MULTIPYTHON_SUBSET="$MULTIPYTHON_ROOT/subset"
MULTIPYTHON_SYS="$MULTIPYTHON_ROOT/sys"
MULTIPYTHON_INFO="$MULTIPYTHON_ROOT/info.json"

PYENV_ROOT=$(pyenv root)
UV_ROOT=$(uv python dir)

declare -rA TAG_PATTERN=(
  ["py314t"]="Python 3.14.0a3 experimental free-threading build ("
  ["py313t"]="Python 3.13.1 experimental free-threading build ("
  ["py314"]="Python 3.14.0a3 ("
  ["py313"]="Python 3.13.1 ("
  ["py312"]="Python 3.12.8 ("
  ["py311"]="Python 3.11.11 ("
  ["py310"]="Python 3.10.16 ("
  ["py39"]="Python 3.9.21 ("
  ["py38"]="Python 3.8.20 ("
  ["py37"]="Python 3.7.17 ("
  ["py36"]="Python 3.6.15 ("
  ["py35"]="Python 3.5.10"
  ["py27"]="Python 2.7.18"
)


# helpers: tags

_py_short () {
  sed 's/^\([0-9]*\)\.\([0-9]*\)[^t]*\(t\?\)$/\1.\2\3/'
}

_py_tag () {
  _py_short | sed 's/^/py/; s/\.//'
}

_py_ls_long () {
  if [ -d "$PYENV_ROOT/versions" ]; then
    # shellcheck disable=SC2012
    ls -1 "$PYENV_ROOT/versions" | sed 's/\(.*t\)$/t\1/' | sort -rV | sed 's/^t//'
  fi
}

_py_ls_all () {
  _py_ls_long | while IFS= read -r long
  do
    echo "$(_py_tag <<<"$long")" "$(_py_short <<<"$long")" "$long"
  done
}

# helpers: sys

_propose_sys_tag () {
  # first, try stable CPyton w/o free threading
  PYTHON_VER="$(_py_ls_long | sed '/[0-9]\(a\|b\|rc\)/d; /t$/d' | head -1)"
  if [ -z "$PYTHON_VER" ]; then
    # second, try latest CPython
    PYTHON_VER="$(_py_ls_long | sed '/t$/d' | head -1)"
    if [ -z "$PYTHON_VER" ]; then
      # third, use whatever latest CPython
      PYTHON_VER="$(_py_ls_long | head -1)"
    fi
  fi
  echo "$PYTHON_VER" | _py_tag
}

# helpers: pip

_pip_install () {
  EXECUTABLE="$1"
  shift
  case "$(py_tag "$EXECUTABLE")" in
    py27) PIP_ARGS="--no-cache-dir" ;;
    py35) PIP_ARGS="--no-cache-dir --cert=/etc/ssl/certs/ca-certificates.crt" ;;
    py36) PIP_ARGS="--no-cache-dir" ;;
    *)    PIP_ARGS="--no-cache-dir --root-user-action=ignore" ;;
  esac
  # shellcheck disable=SC2086
  "$EXECUTABLE" -m pip install $PIP_ARGS "$@"
}

_pip_seed_bindir () {
  BINDIR="$1"
  SEED_MARK="$BINDIR/.multipython"
  if [ ! -e "$SEED_MARK" ]; then
    _pip_install "$BINDIR/python" -U pip setuptools wheel
    touch "$SEED_MARK"
  fi
}

_pip_install_system () {
  SYS_TAG="$(_propose_sys_tag)"

  # determine system virtualenv version requirements
  PY_MIN="$(_py_ls_long | _py_short | sed 's/^[^0-9]\+//' | sort -V | head -1)"
  if [ "$PY_MIN" = "$(echo -e "3.6\n$PY_MIN" | sort -V | head -1)" ]; then
    # PY_MIN<=3.6
    VENV="virtualenv>=20,<20.22"
  elif [ "$PY_MIN" = "$(echo -e "3.7\n$PY_MIN" | sort -V | head -1)" ]; then
    # PY_MIN<=3.7
    VENV="virtualenv>=20,<20.27"
  else
    VENV="virtualenv>=20"
  fi

  # install virtualenv in sys tag, create sys venv, and remove virtualenv
  SYS_TAG_PYTHON="$(py_bin --path "$SYS_TAG")"
  _pip_install "$SYS_TAG_PYTHON" virtualenv
  test -h "$MULTIPYTHON_SYS" && unlink "$MULTIPYTHON_SYS"
  "$SYS_TAG_PYTHON" -m virtualenv --discovery=builtin "$MULTIPYTHON_SYS"
  "$SYS_TAG_PYTHON" -m pip uninstall -y virtualenv

  # seed system environment
  _pip_seed_bindir "$MULTIPYTHON_SYS/bin"
  PYTHON="$MULTIPYTHON_SYS/bin/python"

  # install tox, virtualenv, and plugins
  _pip_install "$PYTHON" "$VENV" tox \
    "virtualenv-multipython==$VIRTUALENV_MULTIPYTHON_VERSION"
  TOX_MAJOR="$("$PYTHON" -m tox -q --version 2>/dev/null | cut -c1)"
  if [ "$TOX_MAJOR" = "3" ]; then
    _pip_install "$PYTHON" "tox-multipython==$TOX_MULTIPYTHON_VERSION"
  fi
}


# commands

py_bin () {
  # helpers
  _filter_tag () {
    if [ "$1" = "" ]; then
      cat
    else
      sed -n '/^'"$1"' /p'
    fi
  }
  _to_bin () {
    case $1 in
      --cmd)  awk '{print "python"$2}' ;;
      --dir)  awk '{print "'"$PYENV_ROOT/versions/"'"$3"/bin"}' ;;
      --path) awk '{print "'"$PYENV_ROOT/versions/"'"$3"/bin/python"}' ;;
    esac
  }
  # parse options
  if [ "$#" = 0 ]; then
    echo "Option required" >&2
    exit 1
  else
    case $1 in
      -c|--cmd) OPTION=--cmd; shift ;;
      -d|--dir) OPTION=--dir; shift ;;
      -p|--path) OPTION=--path; shift ;;
      *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
    esac
  fi
  # run
  _py_ls_all | _filter_tag "${1:-}" | _to_bin "$OPTION"
}

py_info () {
  # parse options
  if [ "$#" -gt 0 ]; then
    case $1 in
      -c|--cached)
        cat $MULTIPYTHON_INFO
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
    esac
  fi

  SYS_TAG="$(py_sys)"

  _python_info () {
    while IFS= read -r line || [ -n "$line" ]
    do
      IFS=' ' read -r tag short long comma <<<"$line"
      PYTHON="$(py_bin -c "$tag")"
      if [ "$tag" = "$SYS_TAG" ]; then
        IS_SYSTEM=true
      else
        IS_SYSTEM=false
      fi
      echo '    {'
      echo '      "version": "'"$long"'",'
      echo '      "source": "pyenv",'
      echo '      "tag": "'"$tag"'",'
      echo '      "short": "'"$short"'",'
      echo '      "command": "'"$PYTHON"'",'
      echo '      "bin_dir": "'"$(py_bin -d "$tag")"'",'
      echo '      "binary_path": "'"$(py_bin -p "$tag")"'",'
      echo '      "is_system": '"$IS_SYSTEM"','
      echo '      "packages": {'
      "$PYTHON" -m pip freeze --all | sed 's/^/        "/; s/==/": "/; s/$/"/; $! s/$/,/'
      echo '      }'
      echo '    }'"$comma"
    done
  }

  PYENV_VER="$(pyenv --version 2>/dev/null | cut -d' ' -f2)"
  TOX_VER="$( (tox -q --version 2>/dev/null | cut -d' ' -f1) || echo "" )"
  UV_VER="$(uv --version 2>/dev/null | cut -d' ' -f2)"
  VENV_VER="$( (virtualenv --version 2>/dev/null | cut -d' ' -f2) || echo "" )"

  echo '{'
  echo '  "multipython": {'
  echo '    "version": "'$MULTIPYTHON_VERSION'",'
  echo '    "subset": "'"$(cat $MULTIPYTHON_SUBSET)"'",'
  echo '    "root": "'$MULTIPYTHON_ROOT'"'
  echo '  },'
    if [ -e "$MULTIPYTHON_SYS/bin/python" ]; then
    echo '  "sys": {'
    echo '    "tag": "'"$SYS_TAG"'",'
    echo '    "root": "'"$MULTIPYTHON_SYS"'",'
    echo '    "bin_dir": "'"$MULTIPYTHON_SYS/bin"'"'
    echo '  },'
  fi
  if [ -n "$PYENV_VER" ]; then
    echo '  "pyenv": {'
    echo '    "version": "'"$PYENV_VER"'",'
    echo '    "root": "'"$PYENV_ROOT"'",'
    echo '    "python_versions": "'"$PYENV_ROOT/versions"'"'
    echo '  },'
  fi
  if [ -n "$UV_VER" ]; then
    echo '  "uv": {'
    echo '    "version": "'"$UV_VER"'"',
    echo '    "python_versions": "'"$UV_ROOT"'"'
    echo '  },'
  fi
  if [ -n "$TOX_VER" ]; then
    echo '  "tox": {'
    echo '    "version": "'"$TOX_VER"'"'
    echo '  },'
  fi
  if [ -n "$VENV_VER" ]; then
    echo '  "virtualenv": {'
    echo '    "version": "'"$VENV_VER"'"'
    echo '  },'
  fi
  echo '  "base_image": {'
  echo '    "name": "debian",'
  echo '    "channel": "stable-slim",'
  echo '    "digest": "'"$(cat $MULTIPYTHON_BASE_IMAGE_DIGEST)"'"'
  echo '  },'

  if [ "$(_py_ls_long)" == "" ]; then
    echo '  "python": []'
  else
    echo '  "python": ['
    _py_ls_all | sed '$ ! s/$/ ,/; $ s/$/ /' | _python_info
    echo '  ]'
  fi
  echo '}'
}

py_install () {
  # require some tags
  if [ -z "$(_py_ls_long)" ]; then
    echo "No Python distributions found" >&2
    exit 1
  fi

  # internal options
  if [ $# = 0 ]; then
    echo "custom" > "$MULTIPYTHON_SUBSET"
  elif [ "$1" = "--as" ]; then
    echo "$2" > "$MULTIPYTHON_SUBSET"
    shift; shift
  fi

  # symlink commands
  paste -d' ' \
    <(_py_ls_all | py_bin -p) \
    <(_py_ls_all | awk '{print "/usr/local/bin/python"$2}') \
  | xargs -r -I% sh -c 'ln -s %'

  # seed tags
  py_bin --dir | while read -r BINDIR; do
    _pip_seed_bindir "$BINDIR"
  done

  # provision system environment
  _pip_install_system

  # generate and validate versions info
  py_info | tee "$MULTIPYTHON_INFO" | jq
}

py_ls () {
  if [ "$#" = 0 ]; then
    echo "Option required" >&2
    exit 1
  else
    case $1 in
      -l|--long) _py_ls_long ;;
      -s|--short) _py_ls_long | _py_short ;;
      -t|--tag) _py_ls_long | _py_tag ;;
      -a|--all) _py_ls_all ;;
      *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
    esac
  fi
}

py_sys () {
  if [ -z "$(command -v python)" ]; then
    exit 0
  fi
  py_tag python
}

py_tag () {
  if [ "$#" = 0 ]; then
    echo "Option required" >&2
    exit 1
  fi
  if [ -z "$(command -v "$1")" ] && [ ! -f "$1" ]; then
    echo "Executable does not exist: $1" >&2
    exit 1
  fi
  HEADER="$("$1" -VV 2>&1 | head -1)"
  for TAG in "${!TAG_PATTERN[@]}"
  do
    if [[ "$HEADER" == "${TAG_PATTERN[$TAG]}"* ]]; then
      echo "$TAG"
      exit 0
    fi
  done
  echo "Unknown executable: $HEADER"
  exit 1
}

py_usage () {
  echo "usage: py bin {--cmd|--dir|--path} [TAG]"
  echo "       py info [--cached]"
  echo "       py install"
  echo "       py ls {--long|--short|--tag|--all}"
  echo "       py root"
  echo "       py sys"
  echo "       py tag <EXECUTABLE>"
  echo "       py --version"
  echo "       py --help"
  echo
  echo "commands:"
  echo "  bin      Show Python executable command or path"
  echo "  info     Extended details in JSON format"
  echo "  install  Install sys environment, commands, and seed packages"
  echo "  ls       List all distributions"
  echo "  root     Show multipython root path"
  echo "  sys      Show system python tag"
  echo "  tag      Determine tag of executable"
  echo
  echo "binary info formats:"
  echo "  -c --cmd   Command name, expected to be on PATH"
  echo "  -d --dir   Path to distribution bin directory"
  echo "  -p --path  Path to distribution binary"
  echo
  echo "version formats:"
  echo "  -l --long   Full version without prefix, e.g. 3.9.12"
  echo "  -s --short  Short version without prefix, e.g. 3.9"
  echo "  -t --tag    Python tag, e.g. py39, pp19"
  echo "  -a --all    Lines 'tag short long', e.g. 'py39 3.9 3.9.3'"
  echo
  echo "other options:"
  echo "  -c --cached  Show cached results"
  echo "  --version    Show multipython distribution version"
  echo "  --help       Show this help and exit"
}

# main

main () {
  if [ $# = 0 ]; then
    py_usage
  else
    case $1 in
      bin)       shift; py_bin "$@" ;;
      checkupd)  bash "$MULTIPYTHON_ROOT/checkupd.sh" ;;  # internal, undocumented
      info)      shift; py_info "$@" ;;
      install)   shift; py_install "$@" ;;
      ls)        shift; py_ls "$@" ;;
      root)      echo "$MULTIPYTHON_ROOT" ;;
      sys)       shift; py_sys "$@" ;;
      tag)       shift; py_tag "$@" ;;
      --version) echo "multipython $MULTIPYTHON_VERSION" ;;
      --help)    py_usage ;;
      *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
    esac
  fi
}

main "$@"
