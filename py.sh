#!/bin/bash

MULTIPYTHON_ROOT=/root/.multipython
MULTIPYTHON_VERSION=2024.12.26


# helpers

py_ls_long () {
  find "$(pyenv root)"/versions -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2> /dev/null \
    | sed 's/$/-/; s/\.\([0-9][^0-9]\)/\.0\1/g' \
    | sort \
    | sed 's/-$//; s/\.0\([0-9]\)/\.\1/g'
}

py_short () {
  sed 's/^\([0-9]*\)\.\([0-9]*\)[^t]*\(t\?\)$/\1.\2\3/'
}

py_nodot () {
  py_short | sed 's/\.//'
}

py_tag () {
  py_short | sed 's/^/py/; s/\.//'
}

py_pkg_version () {
  EXEC=$1
  PKG=$2
  $EXEC -c "import $PKG; print($PKG.__version__)"
}

# commands

py_binary () {
  LINE="$(py_ls_long | py_tag | xargs -n1 | grep -nw "$2" | cut -d: -f1)"
  LONG=$(py_ls_long | sed -n "$LINE p")
  case $1 in
    --name) echo "python$(echo "$LONG" | py_short)" ;;
    --path) echo "$(pyenv root)/versions/$LONG/bin/python" ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
}

py_info () {
  if [ $# -ge 1 ]; then
    case $1 in
      -c | --cached)
        cat $MULTIPYTHON_ROOT/info.json
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  fi

  readarray -t LONG <<<"$(py_ls_long)"
  readarray -t TAG <<<"$(py_ls_long | py_tag)"
  readarray -t SHORT <<<"$(py_ls_long | py_short)"
  readarray -t NODOT <<<"$(py_ls_long | py_nodot)"
  SYSLONG=$(py_version --sys 2>/dev/null || echo -n "")
  PYENV_ROOT=$(pyenv root)
  N=${#LONG[@]}

  TOX_V="$((tox -q --version 2>/dev/null | cut -d' ' -f1) || echo -n "")"

  echo '{'
  echo '  "multipython": {'
  echo '     "debian_image_digest": "'"$(cat $MULTIPYTHON_ROOT/debian_image_digest)"'",'
  echo '     "root": "'$MULTIPYTHON_ROOT'",'
  echo '  },'
  echo '  "debian_image_digest": "'"$(cat $MULTIPYTHON_ROOT/debian_image_digest)"'",'
  echo -e '  "pyenv": {\n    "version": "'"$(pyenv --version | cut -d' ' -f2)"'"\n  }'
  if [ "$TOX_V" != "" ]; then
    echo -e '  "tox": {\n    "version": "'"$(tox -q --version | cut -d' ' -f1)"'"\n  }'
  fi
  echo -e '  "uv": {\n    "version": "'"$(uv --version | cut -d' ' -f2)"'"\n  }'
  if [ "${LONG[0]}" != "" ]; then
    echo '  "python": ['
    for (( i=0; i<$N; i++ )); do
      echo '    {'
      echo '      "version": "'${LONG[$i]}'",'
      echo '      "manager": "pyenv",'
      echo '      "tag": "'${TAG[$i]}'",'
      echo '      "short": "'${SHORT[$i]}'",'
      echo '      "nodot": "'${NODOT[$i]}'",'
      echo '      "executable_name": "python'${SHORT[$i]}'",'
      echo '      "executable_path": "'"$PYENV_ROOT"'/versions/'"${LONG[$i]}"'/bin/python",'
      echo -n '      "is_system": '
      [[ "$SYSLONG" = "${LONG[$i]}" ]] && echo true, || echo false,
      echo '      "pkg": {'
      echo '        "pip": "'"$(py_pkg_version python${SHORT[$i]} pip)"'",'
      echo '        "setuptools": "'"$(py_pkg_version python${SHORT[$i]} setuptools)"'"'
      echo '      }'
      echo -n '    }'
      [[ "$i" -lt "$N" ]] && echo ","
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
      -n | --nodot) py_ls_long | py_nodot ;;
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
      -n | --nodot) TRANSFORM="py_nodot" ;;
      *)
        echo "Unknown option: $2"
        exit 1
        ;;
    esac
  fi
  case $1 in
    --min) py_ls_long | head -1 | sed 's/t$//' | $TRANSFORM ;;
    --max) py_ls_long | tail -1 | sed 's/t$//' | $TRANSFORM ;;
    --stable) py_ls_long | sed '/a\|b\|rc/d' | tail -1 | sed 's/t$//' | $TRANSFORM ;;
    --sys) python --version | cut -d' ' -f2 | sed 's/t$//' | $TRANSFORM ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
}

py_install () {
  PYENV_ROOT=$(pyenv root)
  # link pyenv
  for v in $(py_ls_long); do
    ln -s "$PYENV_ROOT/versions/$v/bin/python" "/usr/local/bin/python$(echo "$v" | py_short)"
  done
  # link sys
  case $1 in
    --sys)
      test -h "$MULTIPYTHON_ROOT/sys" && unlink "$MULTIPYTHON_ROOT/sys"
      ln -s "$(dirname "$(py_binary --path "$2")")" "$MULTIPYTHON_ROOT/sys"
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  # install tox
  if [ "$3" == "--tox" ]; then
    PYMIN=$(py_version --min --nodot)
    # shellcheck disable=SC2071
    if [[ "$PYMIN" < "37" ]]; then
      spec="virtualenv<20.22"
    elif [[ "$PYMIN" < "38" ]]; then
      spec="virtualenv<20.27"
    else
      spec="virtualenv"
    fi
    python -m pip install --disable-pip-version-check --root-user-action=ignore --no-cache-dir $spec tox
  elif [ "$3" != "" ]; then
    echo "Unknown option: $3"
    exit 1
  fi
}

py_usage () {
  echo "usage: py ls [--long|--short|--nodot|--tag]"
  echo "       py version (--min|--max|--stable|--sys) [--long|--short|--nodot]"
  echo "       py binary (--name|--path) <tag>"
  echo "       py install --sys <tag> [--tox]"
  echo "       py root"
  echo "       py info [--cached]"
  echo "       py --version"
  echo "       py --help"
  echo
  echo "commands:"
  echo "  binary   Show path to Python binary"
  echo "  info     Extended details in JSON format"
  echo "  install  Install optional packages and create symlinks"
  echo "  ls       List all distributions"
  echo "  root     Show multipython root path"
  echo "  version  Show specific python version"
  echo
  echo "version options:"
  echo "  -l --long   Full version without prefix, e.g. 3.9.12"
  echo "  -s --short  Short version without prefix, e.g. 3.9"
  echo "  -n --nodot  Short version without prefix and dots, e.g. 39"
  echo "  -t --tag    Python tag, e.g. py39, pp19"
  echo "  --min       Lowest installed version"
  echo "  --max       Highest installed version"
  echo "  --stable    Highest release version"
  echo "  --sys       System python version"
  echo
  echo "other options:"
  echo "  -c --cached  Show cached results"
  echo "  --tox        Install tox"
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
      binary) py_binary $2 $3 ;;
      info) py_info $2 ;;
      install) py_install $2 $3 $4 ;;
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
