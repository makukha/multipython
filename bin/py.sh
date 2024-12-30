#!/bin/bash

MULTIPYTHON_ROOT=/root/.multipython
MULTIPYTHON_VERSION=2024.12.27
MULTIPYTHON_INFO="$MULTIPYTHON_ROOT/info.json"

PYENV_ROOT=$(pyenv root)

# helpers

py_ls_long () {
  find "$PYENV_ROOT/versions" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2> /dev/null \
    | sed 's/$/-/; s/\.\([0-9][^0-9]\)/\.0\1/g' \
    | sort \
    | sed 's/-$//; s/\.0\([0-9]\)/\.\1/g'
}

py_short () {
  sed 's/^\([0-9]*\)\.\([0-9]*\)[^t]*\(t\?\)$/\1.\2\3/'
}

py_tag () {
  py_short | sed 's/^/py/; s/\.//'
}

pip_pkg_version () {
  $1 -m pip show --version "$2" 2>/dev/null | grep Version: | cut -d' ' -f2
}

# commands

py_bin () {
  readarray -t LONG < <(py_ls_long)
  readarray -t SHORT < <(py_short <<<"${LONG[*]}")
  readarray -t TAG < <(py_tag <<<"${LONG[*]}")

  if [ "$1" = "--path" ]; then
    REQ="$2"
  else
    REQ="$1"
  fi

  for (( i=0; i<${#LONG[*]}; i++ ))
  do
    if [[ "$REQ" == "${LONG[$i]}" || "$1" == "${SHORT[$i]}" || "$1" == "${TAG[$i]}" ]]
    then
      if [ "$1" = "--path" ]; then
        echo "$PYENV_ROOT/versions/${LONG[$i]}/bin/python"
      else
        echo "python${SHORT[$i]}"
      fi
      exit 0
    fi
  done

  echo "Python version not found: $REQ"
  exit 1
}

py_info () {
  if [ $# -ge 1 ]; then
    case $1 in
      -c | --cached)
        cat $MULTIPYTHON_INFO
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  fi

  readarray -t LONG < <(py_ls_long)
  readarray -t SHORT < <(py_short <<<"${LONG[*]}")
  readarray -t TAG < <(py_tag <<<"${LONG[*]}")
  LONG_SYS=$(py_version sys 2>/dev/null || echo -n "")

  PYENV_VER="$(pyenv --version 2>/dev/null | cut -d' ' -f2)"
  PYENV_PYDIR="$PYENV_ROOT/versions"

  UV_VER="$(uv --version 2>/dev/null | cut -d' ' -f2)"
  UV_PYDIR="$(uv python dir)"

  TOX_VER="$( (tox -q --version 2>/dev/null | cut -d' ' -f1) || echo -n "" )"

  echo '{'
  echo '  "multipython": {'
  echo '     "version": "'$MULTIPYTHON_VERSION'",'
  echo '     "root": "'$MULTIPYTHON_ROOT'"'
  echo '  },'
  if [ "$PYENV_VER" != "" ]; then
    echo '  "pyenv": {'
    echo '    "version": "'"$PYENV_VER"'",'
    echo '    "root": "'"$PYENV_ROOT"'",'
    echo '    "python_versions": "'"$PYENV_PYDIR"'"'
    echo '  },'
  fi
  if [ "$TOX_VER" != "" ]; then
    echo '  "tox": {'
    echo '    "version": "'"$TOX_VER"'"'
    echo '  },'
  fi
  if [ "$UV_VER" != "" ]; then
    echo '  "uv": {'
    echo '    "version": "'"$UV_VER"'"',
    echo '    "python_versions": "'"$UV_PYDIR"'"'
    echo '  },'
  fi
  echo '  "debian": {'
  echo '    "docker_channel": "stable-slim",'
  echo '    "docker_image_digest": "'"$(cat $MULTIPYTHON_ROOT/debian_image_digest)"'"'
  echo '  },'

  if [ "${LONG[*]}" = "" ]; then
    echo '  "python": []'
  else
    echo '  "python": ['
    for (( i=0; i<${#LONG[*]}; i++ ))
    do
      PY_BIN="$(py_bin "${LONG[$i]}")"
      PY_BIN_PATH="$(py_bin --path "${LONG[$i]}")"
      PIP_VER=$(pip_pkg_version "$PY_BIN" pip)
      SETUPTOOLS_VER=$(pip_pkg_version "$PY_BIN" setuptools)
      echo '    {'
      echo '      "version": "'"${LONG[$i]}"'",'
      echo '      "source": "pyenv",'
      echo '      "tag": "'"${TAG[$i]}"'",'
      echo '      "short": "'"${SHORT[$i]}"'",'
      echo '      "cmd": "'"$(py_bin "${TAG[$i]}")"'",'
      echo '      "binary_path": "'"$PY_BIN_PATH"'",'
      if [[ "$LONG_SYS" = "${LONG[$i]}" ]]; then
        echo '      "is_system": true,'
      else
        echo '      "is_system": false,'
      fi
      echo '      "packages": {'
      echo '        "pip": "'"$PIP_VER"'",'
      echo '        "setuptools": "'"$SETUPTOOLS_VER"'"'
      echo '      }'
      echo -n '    }'
      if (( i = ${#LONG[*]} )); then echo; else echo ","; fi
    done
    echo '  ]'
  fi

  echo '}'
}

py_ls () {
  if [ $# = 0 ]; then
    py_ls_long
  else
    case $1 in
      -l | --long) py_ls_long ;;
      -s | --short) py_ls_long | py_short ;;
      -t | --tag) py_ls_long | py_tag ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  fi
}

py_version () {
  if [ $# = 1 ]; then
    TRANSFORM="cat"
  else
    case $2 in
      -l | --long) TRANSFORM="cat" ;;
      -s | --short) TRANSFORM="py_short" ;;
      *)
        echo "Unknown option: $2"
        exit 1
        ;;
    esac
  fi
  case $1 in
    min) py_ls_long | head -1 | sed 's/t$//' | $TRANSFORM ;;
    max) py_ls_long | tail -1 | sed 's/t$//' | $TRANSFORM ;;
    stable) py_ls_long | sed '/a\|b\|rc/d' | tail -1 | sed 's/t$//' | $TRANSFORM ;;
    sys) python --version | cut -d' ' -f2 | sed 's/t$//' | $TRANSFORM ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
}

py_install () {
  readarray -t LONG < <(py_ls_long)
  readarray -t SHORT < <(py_short <<<"${LONG[*]}")

  # link pyenv
  for (( i=0; i<${#LONG[*]}; i++ ))
  do
    ln -s "$PYENV_ROOT/versions/${LONG[$i]}/bin/python" "/usr/local/bin/python${SHORT[$i]}"
  done

  # link system executable
  test -h "$MULTIPYTHON_ROOT/sys" && unlink "$MULTIPYTHON_ROOT/sys"
  ln -s "$(dirname "$(py_bin --path "$1")")" "$MULTIPYTHON_ROOT/sys"

  # install or update pip, setuptools, tox
  PYMIN=$(py_version --min --short)
  # shellcheck disable=SC2071
  if [[ "$PYMIN" == "$(echo -e "3.7\n$PYMIN" | sort -V | head -1)" ]]; then
    # $PY_MIN < "3.7"
    spec="virtualenv<20.22"
  elif [[ "$PYMIN" == "$(echo -e "3.8\n$PYMIN" | sort -V | head -1)" ]]; then
    # $PY_MIN < "3.8"
    spec="virtualenv<20.27"
  else
    spec="virtualenv"
  fi
  pip install --disable-pip-version-check --root-user-action=ignore --no-cache-dir \
    -U $spec pip setuptools tox

  # generate and validate versions info
  py_info | tee "$MULTIPYTHON_INFO" | jq
}

py_usage () {
  echo "usage: py bin [--path] <LONG|SHORT|TAG>"
  echo "       py info [--cached]"
  echo "       py install <LONG|SHORT|TAG>"
  echo "       py ls [--long|--short|--tag]"
  echo "       py root"
  echo "       py version min|max|stable|sys [--long|--short]"
  echo "       py --version"
  echo "       py --help"
  echo
  echo "commands:"
  echo "  bin      Show Python executable command or path"
  echo "  info     Extended details in JSON format"
  echo "  install  Install optional packages and create symlinks"
  echo "  ls       List all distributions"
  echo "  root     Show multipython root path"
  echo "  version  Show specific python version"
  echo
  echo "version formats:"
  echo "  -l --long   Full version without prefix, e.g. 3.9.12"
  echo "  -s --short  Short version without prefix, e.g. 3.9"
  echo "  -t --tag    Python tag, e.g. py39, pp19"
  echo
  echo "version choices:"
  echo "  min     Lowest installed version"
  echo "  max     Highest installed version"
  echo "  stable  Highest stable release version"
  echo "  sys     System python version"
  echo
  echo "other options:"
  echo "  -c --cached  Show cached results"
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
      bin) py_bin $2 $3 ;;
      checkupd) bash "$MULTIPYTHON_ROOT/checkupd.sh" ;;
      info) py_info $2 ;;
      install) py_install $2 ;;
      ls) py_ls $2 ;;
      root) echo "$MULTIPYTHON_ROOT" ;;
      version) py_version $2 $3 ;;
      --version) echo "multipython $MULTIPYTHON_VERSION" ;;
      --help) py_usage ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  fi
}

main "$@"
