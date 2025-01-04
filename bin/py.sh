#!/bin/bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

MULTIPYTHON_VERSION=2025.1.3
MULTIPYTHON_ROOT=/root/.multipython
MULTIPYTHON_INFO="$MULTIPYTHON_ROOT/info.json"

PYENV_ROOT=$(pyenv root)


# helpers

py_ls_long () {
  if [ -d "$PYENV_ROOT/versions" ]; then
    ls -1 "$PYENV_ROOT/versions" | sed 's/\(.*t\)$/t\1/' | sort -rV | sed 's/^t//'
  fi
}

py_short () {
  sed 's/^\([0-9]*\)\.\([0-9]*\)[^t]*\(t\?\)$/\1.\2\3/'
}

py_tag () {
  py_short | sed 's/^/py/; s/\.//'
}

_py_sys () {
  # first, try stable CPyton w/o free threading
  PYTHON_VER="$(py_ls_long | sed '/[0-9]\(a\|b\|rc\)/d; /t$/d' | head -1)"
  if [ -z "$PYTHON_VER" ]; then
    # second, try latest CPython
    PYTHON_VER="$(py_ls_long | sed '/t$/d' | head -1)"
    if [ -z "$PYTHON_VER" ]; then
      # third, use whatever latest CPython
      PYTHON_VER="$(py_ls_long | head -1)"
    fi
  fi
  echo "$PYTHON_VER"
}

py_ls_table () {
 paste -d' ' <(py_ls_long) <(py_ls_long | py_short) <(py_ls_long | py_tag)
}


# commands

py_bin () {
  _filter () {
    if [ -z "${1:-}" ]; then
      cat
    else
      sed 's/\(.*\)/ \1 /' | sed -n '/ '"$1"' /p' | sed 's/^ //;s/ $//'
    fi
  }

  _to_bin () {
    case $1 in
      --cmd)  sed 's|^\(\S\+\) \(\S\+\) .*|python\2|' ;;
      --dir)  sed 's|^\(\S\+\) .*|'"$PYENV_ROOT"'/versions/\1/bin|' ;;
      --path) sed 's|^\(\S\+\) .*|'"$PYENV_ROOT"'/versions/\1/bin/python|' ;;
    esac
  }

  # parse options
  if [ -z "${1+x}" ]; then
    TYPE="--cmd"
  elif [ "$1" = "--dir" ] || [ "$1" = "--path" ]; then
    TYPE="$1"; shift
  else
    TYPE="--cmd"
  fi
  ARG="${1:-}"

  # run
  py_ls_table | _filter "$ARG" | _to_bin "$TYPE"
}

py_info () {
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

  PYTHON_VER="$(py_sys)"

  _pip_pkg_version () {
    $1 -m pip show --version "$2" 2>/dev/null | sed -n 's/Version: //p'
  }

  _python_info () {
    while IFS='' read -r line || [ -n "$line" ]
    do
      IFS=' ' read -r LONG SHORT TAG COMMA <<<"$line"
      if [ "$COMMA" = "comma" ]; then
        COMMA=,
      else
        COMMA=
      fi
      PYTHON="$(py_bin "$LONG")"
      echo '    {'
      echo '      "version": "'"$LONG"'",'
      echo '      "source": "pyenv",'
      echo '      "tag": "'"$TAG"'",'
      echo '      "short": "'"$SHORT"'",'
      echo '      "command": "'"$PYTHON"'",'
      echo '      "bin_dir": "'"$(py_bin --dir "$LONG")"'",'
      echo '      "binary_path": "'"$(py_bin --path "$LONG")"'",'
      if [ "$LONG" = "$PYTHON_VER" ]; then
        echo '      "is_system": true,'
      else
        echo '      "is_system": false,'
      fi
      echo '      "packages": {'
      echo '        "pip": "'"$(_pip_pkg_version "$PYTHON" pip)"'",'
      echo -n '        "setuptools": "'"$(_pip_pkg_version "$PYTHON" setuptools)"'"'
      TOX_VER="$(_pip_pkg_version "$PYTHON" tox || echo "")"
      if [ -n "$TOX_VER" ]; then
        echo ','
        echo '        "tox": "'"$TOX_VER"'"'
      else
        echo
      fi
      echo '      }'
      echo '    }'"$COMMA"
    done
  }

  PYENV_VER="$(pyenv --version 2>/dev/null | cut -d' ' -f2)"
  TOX_VER="$( (tox -q --version 2>/dev/null | cut -d' ' -f1) || echo -n "" )"
  UV_VER="$(uv --version 2>/dev/null | cut -d' ' -f2)"
  VENV_VER="$( (virtualenv --version 2>/dev/null | cut -d' ' -f2 ) || echo -n "")"
  VENVMPY_VER="$(_pip_pkg_version "python" virtualenv-multipython || echo -n "")"

  echo '{'
  echo '  "multipython": {'
  echo '    "version": "'$MULTIPYTHON_VERSION'",'
  echo '    "subset": "'"$(cat $MULTIPYTHON_ROOT/subset)"'",'
  echo '    "root": "'$MULTIPYTHON_ROOT'"'
  echo '  },'
  if [ -n "$PYENV_VER" ]; then
    echo '  "pyenv": {'
    echo '    "version": "'"$PYENV_VER"'",'
    echo '    "root": "'"$PYENV_ROOT"'",'
    echo '    "python_versions": "'"$PYENV_ROOT/versions"'"'
    echo '  },'
  fi
  if [ -n "$TOX_VER" ]; then
    echo '  "tox": {'
    echo '    "version": "'"$TOX_VER"'"'
    echo '  },'
  fi
  if [ -n "$UV_VER" ]; then
    echo '  "uv": {'
    echo '    "version": "'"$UV_VER"'"',
    echo '    "python_versions": "'"$(uv python dir)"'"'
    echo '  },'
  fi
  if [ -n "$VENV_VER" ]; then
    echo '  "virtualenv": {'
    echo '    "version": "'"$VENV_VER"'"'
    echo '  },'
  fi
  if [ -n "$VENVMPY_VER" ]; then
    echo '  "virtualenv-multipython": {'
    echo '    "version": "'"$VENVMPY_VER"'"'
    echo '  },'
  fi
  echo '  "base_image": {'
  echo '    "name": "debian",'
  echo '    "channel": "stable-slim",'
  echo '    "digest": "'"$(cat $MULTIPYTHON_ROOT/base_image_digest)"'"'
  echo '  },'

  if [ "$(py_ls_long)" == "" ]; then
    echo '  "python": []'
  else
    echo '  "python": ['
    py_ls_table | sed '$ ! s/$/ comma/; $ s/$/ nothing/' | _python_info
    echo '  ]'
  fi
  echo '}'
}

py_install () {
  # shortcut
  if [ -z "$(py_ls_table)" ]; then
    echo No Python distributions found. >&2
    exit 1
  fi

  # options
  if [ $# = 0 ]; then
    echo "custom" > "$MULTIPYTHON_ROOT/subset"
  elif [ "$1" = "--as" ]; then
    echo "$2" > "$MULTIPYTHON_ROOT/subset"
    shift; shift
  fi

  _pip_install () {
    while IFS=$'\n' read -r short
    do
      case $short in
        2.7) PIP_ARGS="--no-cache-dir" ;;
        3.5) PIP_ARGS="--no-cache-dir --cert=/etc/ssl/certs/ca-certificates.crt" ;;
        3.6) PIP_ARGS="--no-cache-dir" ;;
        *)   PIP_ARGS="--no-cache-dir --root-user-action=ignore" ;;
      esac
      "python$short" -m pip install $PIP_ARGS "$@"
    done
  }

  _pip_uninstall () {
    while IFS=$'\n' read -r short
    do
      "python$short" -m pip uninstall --yes "$@"
    done
  }

  # link individual distributions
  py_ls_table | sed 's|\(\S\+\) \(\S\+\) .*|'"$PYENV_ROOT"'/versions/\1/bin/python /usr/local/bin/python\2|' \
    | xargs -I% sh -c 'ln -s %'

  # install/update individual pip, tox, setuptools
  py_ls_long | py_short | _pip_install -U pip setuptools

  # link system executable
  PYTHON_VER="$(_py_sys)"
  test -h "$MULTIPYTHON_ROOT/sys" && unlink "$MULTIPYTHON_ROOT/sys"
  ln -s "$(py_bin --dir "$PYTHON_VER")" "$MULTIPYTHON_ROOT/sys"

  # uninstall tox in all distributions
  py_ls_long | py_short | _pip_uninstall tox

  # install system tox
  PY_MIN="$(py_ls_long | py_short | sed 's/^[^0-9]\+//' | sort -V | head -1)"
  if [ "$PY_MIN" = "$(echo -e "3.6\n$PY_MIN" | sort -V | head -1)" ]; then
    # PY_MIN<=3.6
    TOX_PIN="virtualenv<20.22"
  elif [ "$PY_MIN" = "$(echo -e "3.7\n$PY_MIN" | sort -V | head -1)" ]; then
    # PY_MIN<=3.7
    TOX_PIN="virtualenv<20.27"
  else
    TOX_PIN="virtualenv"
  fi
  echo "$PYTHON_VER" | py_short | _pip_install "$TOX_PIN" tox

  # install virtualenv-multipython if possible (except py27)
  echo "$PYTHON_VER" | py_short | _pip_install virtualenv-multipython || true

  # generate and validate versions info
  py_info | tee "$MULTIPYTHON_INFO" | jq
}

py_ls () {
  if [ $# = 0 ]; then
    py_ls_long
  else
    case $1 in
      -l|--long) py_ls_long ;;
      -s|--short) py_ls_long | py_short ;;
      -t|--tag) py_ls_long | py_tag ;;
      --table) py_ls_table ;;
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

  if [ $# = 0 ]; then
    OPT=--long
  else
    OPT="$1"
  fi

  VERB="$(python -VV | head -1 | sed 's/ (.*/ (/')"
  TAG="$(sed -n "s/ $VERB$//p" "$MULTIPYTHON_ROOT/verbose.txt")"

  case $OPT in
    --long) py_ls_table | sed -n '/ '"$TAG"'$/p' | cut -d' ' -f1 ;;
    --short) py_ls_table | sed -n '/ '"$TAG"'$/p' | cut -d' ' -f2 ;;
    --tag) echo "$TAG" ;;
    --table) py_ls_table | sed -n '/ '"$TAG"'$/p' ;;
    *)
      echo "Unknown option: $OPT" >&2
      exit 1
      ;;
  esac
}

py_usage () {
  echo "usage: py bin [--dir|--path] <LONG|SHORT|TAG>"
  echo "       py info [--cached]"
  echo "       py install"
  echo "       py ls [--long|--short|--tag|--table]"
  echo "       py root"
  echo "       py sys [--long|--short|--tag|--table]"
  echo "       py --version"
  echo "       py --help"
  echo
  echo "commands:"
  echo "  bin      Show Python executable command or path"
  echo "  info     Extended details in JSON format"
  echo "  install  Install optional packages and symlinks"
  echo "  ls       List all distributions"
  echo "  root     Show multipython root path"
  echo "  sys      Show system python version"
  echo
  echo "version formats:"
  echo "  -l --long   Full version without prefix, e.g. 3.9.12"
  echo "  -s --short  Short version without prefix, e.g. 3.9"
  echo "  -t --tag    Python tag, e.g. py39, pp19"
  echo "     --table  Lines 'long short tag', e.g. '3.9.3 3.9 py39'"
  echo
  echo "other options:"
  echo "  -c --cached  Show cached results"
  echo "  --dir        Path to distribution bin directory"
  echo "  --path       Path to distribution binary"
  echo "  --version    Show multipython distribution version"
  echo "  --help       Show this help and exit"
}

# main

main () {
  if [ $# = 0 ]; then
    py_usage
  else
    # shellcheck disable=SC2086
    case $1 in
      bin)       shift; py_bin "$@" ;;
      checkupd)  bash "$MULTIPYTHON_ROOT/checkupd.sh" ;;  # internal, undocumented
      info)      shift; py_info "$@" ;;
      install)   shift; py_install "$@" ;;
      ls)        shift; py_ls "$@" ;;
      root)      echo "$MULTIPYTHON_ROOT" ;;
      sys)       shift; py_sys "$@" ;;
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
