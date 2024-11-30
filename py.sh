#!/bin/sh

# versions

py_pyenv () {
  find ${PYENV_ROOT}/versions -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2> /dev/null
}
py_sys () {
  python --version | sed -e's/Python //'
}
py_versions () {
  py_pyenv
  py_sys
}

# version conversions

py_minor () {
  sed -e "s/^\([0-9]*\)\.\([0-9]*\)[^t]*\(t\?\)$/\1.\2\3/"
}

py_tag () {
  py_minor | sed -e "s/^/py/; s/\.//"
}

py_sort () {
  sed -e 's/\.\([0-9][^0-9]\)/\.0\1/g' | sort | sed -e 's/\.0\([0-9]\)/\.\1/g'
}

to_minor () {
  if [ -n "$1" ]; then
    echo "$1" | py_minor
  else
    py_minor
  fi
}

to_tag () {
  if [ -n "$1" ]; then
    echo "$1" | py_tag
  else
    py_tag
  fi
}

# commands

py_install () {
  py_pyenv | xargs pyenv global system
  for v in $(py_pyenv); do
    ln -s "${PYENV_ROOT}/versions/$v/bin/python" "/usr/local/bin/python$(echo $v | py_minor)"
  done
}

py_usage () {
  echo "Usage: py <option>\n"
  echo "  Multipython helper utility."
  echo "\nOptions:"
  echo "  --list   Show all versions installed"
  echo "  --minor  Show minor versions installed"
  echo "  --tags   Show tags of versions installed"
  echo "  --pyenv  Show versions managed by pyenv"
  echo "  --sys    Show version of system python"
  echo "  --help   Show this help and exit"
  echo "\nOther options:"
  echo "  --install   Set pyenv globals and symlink (use in Dockerfile only)"
  echo "  --to-minor  Convert full version from stdin/arg to minor format"
  echo "  --to-tag    Convert full version from stdin/arg to tag format"
}

# main

main () {
  if [ "$#" = "0" ]; then
    py_usage
    exit 0
  fi

  case $1 in
    # main options
    --list)  py_versions | py_sort ;;
    --minor) py_versions | py_sort | py_minor ;;
    --tags)  py_versions | py_sort | py_tag ;;
    --pyenv) py_pyenv | py_sort ;;
    --sys) py_sys ;;
    --help) py_usage ;;
    # other options
    --install) py_install ;;
    --to-minor) to_minor "$2" ;;
    --to-tag) to_tag "$2" ;;
    *)
      echo "Unknown option:" $1
      exit 1
      ;;
  esac

  exit 0
}

main "$@"
