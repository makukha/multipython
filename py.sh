#!/bin/sh

MULTIPYTHON_ROOT=/root/.multipython

# versions

py_list () {
  find "$(pyenv root)"/versions -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2> /dev/null
}
py_sys () {
  python --version | cut -d' ' -f2
}

# version conversions

py_minor () {
  sed -e "s/^\([0-9]*\)\.\([0-9]*\)[^t]*\(t\?\)$/\1.\2\3/"
}

py_tag () {
  py_minor | sed -e "s/^/py/; s/\.//"
}

py_sort () {
  sed -e 's/$/-/; s/\.\([0-9][^0-9]\)/\.0\1/g' | sort | sed -e 's/-$//; s/\.0\([0-9]\)/\.\1/g'
}

to_minor () {
  if [ "$1" = "-" ]; then
    py_minor
  else
    echo "$1" | py_minor
  fi
}

to_tag () {
  if [ "$1" = "-" ]; then
    py_tag
  else
    echo "$1" | py_tag
  fi
}

# commands

py_link_pyenv () {
  PYENV_ROOT=$(pyenv root)
  for v in $(py_list); do
    ln -s "$PYENV_ROOT/versions/$v/bin/python" "/usr/local/bin/python$(to_minor "$v")"
  done
}
py_link_sys () {
  PYENV_ROOT=$(pyenv root)
  MULTIPYTHON_ROOT=$(py --root)
  for v in $(py_list); do
    if [ "$(py --to-tag "$v")" = "$1" ]; then
      test -h "$MULTIPYTHON_ROOT/sys" && unlink "$MULTIPYTHON_ROOT/sys"
      ln -s "$PYENV_ROOT/versions/$v/bin" "$MULTIPYTHON_ROOT/sys"
    fi
  done
}

py_usage () {
  echo "Usage: py <option>"
  echo
  echo "  Multipython helper utility."
  echo
  echo "Options:"
  echo "  --list   Show all versions installed"
  echo "  --minor  Show minor versions installed"
  echo "  --tags   Show tags of versions installed"
  echo "  --sys    Show version of system python"
  echo "  --help   Show this help and exit"
  echo
  echo "Advanced options:"
  echo "  --link-pyenv      Symlink all python versions (use in Dockerfile only)"
  echo "  --link-sys VER    Symlink system python (use in Dockerfile only)"
  echo "  --root            Show path to multipython root directory"
  echo "  --to-minor -|VER  Convert full version from stdin or value to minor format"
  echo "  --to-tag -|VER    Convert full version from stdin or value to tag format"
}

# main

main () {
  if [ "$#" = "0" ]; then
    py_usage
    exit 0
  fi

  case $1 in
    # main options
    --list)  py_list | py_sort ;;
    --minor) py_list | py_sort | py_minor ;;
    --tags)  py_list | py_sort | py_tag ;;
    --sys) py_sys ;;
    --help) py_usage ;;
    # advanced options
    --link-pyenv) py_link_pyenv ;;
    --link-sys) py_link_sys "$2" ;;
    --root) echo "$MULTIPYTHON_ROOT" ;;
    --to-minor) to_minor "$2" ;;
    --to-tag) to_tag "$2" ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac

  exit 0
}

main "$@"
