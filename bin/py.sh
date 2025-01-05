#!/bin/bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

MULTIPYTHON_VERSION=2513
MULTIPYTHON_ROOT=/root/.multipython
MULTIPYTHON_INFO="$MULTIPYTHON_ROOT/info.json"

PYENV_ROOT=$(pyenv root)
UV_ROOT=$(uv python dir)


# helpers

_py_ls_long () {
  if [ -d "$PYENV_ROOT/versions" ]; then
    ls -1 "$PYENV_ROOT/versions" | sed 's/\(.*t\)$/t\1/' | sort -rV | sed 's/^t//'
  fi
}

_py_short () {
  sed 's/^\([0-9]*\)\.\([0-9]*\)[^t]*\(t\?\)$/\1.\2\3/'
}

_py_tag () {
  _py_short | sed 's/^/py/; s/\.//'
}

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

_py_ls_all () {
  _py_ls_long | while IFS= read -r long
  do
    echo "$(_py_tag <<<"$long")" "$(_py_short <<<"$long")" "$long"
  done
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
    echo '    "python_versions": "'"$UV_ROOT"'"'
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
  echo '    "digest": "'"$(cat $MULTIPYTHON_ROOT/base_image_digest)"'"'
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
  # shortcut
  if [ -z "$(_py_ls_all)" ]; then
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

  _pip_snapshot_file () {
    echo "$(py_bin -d "$1")/../lib/.multipython.original"
  }

  _all_pip_snapshot () {
    while IFS=$'\n' read -r tag
    do
      FN="$(_pip_snapshot_file "$tag")"
      PIP="$(py_bin -p "$tag") -m pip"
      if [ ! -f "$FN" ]; then
        $PIP freeze --all 2>/dev/null > "$FN"
      fi
    done
  }

  _all_pip_rollback () {
    while IFS=$'\n' read -r tag
    do
      FN="$(_pip_snapshot_file "$tag")"
      PIP="$(py_bin -p "$tag") -m pip"
      if [ -f "$FN" ]; then
        $PIP freeze 2>/dev/null | xargs -r $PIP uninstall -y
        _all_pip_install -r "$FN" <<<"$tag"
      else
        echo "Snapshot not available: $FN" >&2
        exit 1
      fi
    done
  }

  _all_pip_ensure_original () {
    while IFS=$'\n' read -r tag
    do
      FN="$(_pip_snapshot_file "$tag")"
      if [ ! -f "$FN" ]; then
        _all_pip_snapshot <<<"$tag"
      else
        _all_pip_rollback <<<"$tag"
      fi
    done
  }

  _all_pip_install () {
    while IFS=$'\n' read -r tag
    do
      short="$(_py_ls_all | sed -n '/^'"$tag"'/p' | awk '{print $2}')"
      case $short in
        2.7) PIP_ARGS="--no-cache-dir" ;;
        3.5) PIP_ARGS="--no-cache-dir --cert=/etc/ssl/certs/ca-certificates.crt" ;;
        3.6) PIP_ARGS="--no-cache-dir" ;;
        *)   PIP_ARGS="--no-cache-dir --root-user-action=ignore" ;;
      esac
      "$(py_bin -p "$tag")" -m pip install $PIP_ARGS "$@"
    done
  }

  # link individual distributions
  paste -d' ' \
    <(_py_ls_all | py_bin -p) \
    <(_py_ls_all | awk '{print "/usr/local/bin/python"$2}') \
  | xargs -r -I% sh -c 'ln -s %'

  # install/update individual pip and setuptools
  py_ls -t | _all_pip_install -U pip setuptools

  # freeze or roll back to original state
  py_ls -t | _all_pip_ensure_original

  # link system executable
  SYS_TAG="$(_propose_sys_tag)"
  test -h "$MULTIPYTHON_ROOT/sys" && unlink "$MULTIPYTHON_ROOT/sys"
  ln -s "$(py_bin -d "$SYS_TAG")" "$MULTIPYTHON_ROOT/sys"

  # determine min tox version
  PY_MIN="$(_py_ls_long | _py_short | sed 's/^[^0-9]\+//' | sort -V | head -1)"
  if [ "$PY_MIN" = "$(echo -e "3.6\n$PY_MIN" | sort -V | head -1)" ]; then
    # PY_MIN<=3.6
    TOX_PIN="virtualenv<20.22"
  elif [ "$PY_MIN" = "$(echo -e "3.7\n$PY_MIN" | sort -V | head -1)" ]; then
    # PY_MIN<=3.7
    TOX_PIN="virtualenv<20.27"
  else
    TOX_PIN="virtualenv"
  fi

  # install system tox and plugins
  py_sys | _all_pip_install --force-reinstall "$TOX_PIN" tox virtualenv-multipython

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
  VERB="$(python -VV 2>&1 | head -1 | sed 's/ (.*/ (/')"
  sed -n "s/ $VERB$//p" "$MULTIPYTHON_ROOT/verbose.txt"
}

py_usage () {
  echo "usage: py bin {--cmd|--dir|--path} [TAG]"
  echo "       py info [--cached]"
  echo "       py install"
  echo "       py ls {--long|--short|--tag|--all}"
  echo "       py root"
  echo "       py sys"
  echo "       py --version"
  echo "       py --help"
  echo
  echo "commands:"
  echo "  bin      Show Python executable command or path"
  echo "  info     Extended details in JSON format"
  echo "  install  Install optional packages and symlinks"
  echo "  ls       List all distributions"
  echo "  root     Show multipython root path"
  echo "  sys      Show system python tag"
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
