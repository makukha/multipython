#!/bin/sh

# versions

py_pyenv () {
  find ${PYENV_ROOT}/versions -mindepth 1 -maxdepth 1 -type d -printf "%f\n"
}
py_sys () {
  python --version | sed -e's/Python //'
}
py_versions () {
  py_pyenv
  py_sys
}

# string operations

py_minor () {
  sed -e "s/^\([0-9]*\)\.\([0-9]*\)[^t]*\(t\?\)$/\1.\2\3/"
}

py_tag () {
  py_minor | sed -e "s/^/py/; s/\.//"
}

py_sort () {
  sed -e 's/\.\([0-9][^0-9]\)/\.0\1/g' | sort | sed -e 's/\.0\([0-9]\)/\.\1/g'
}

# commands

py_install () {
  py_pyenv | xargs pyenv global system
  for v in $(py_pyenv); do
    ln -s "${PYENV_ROOT}/versions/$v/bin/python" "/usr/local/bin/python$(echo $v | py_minor)"
  done
}

py_usage () {
  echo "usage: py <option>"
  echo "  options:"
  echo "    --list     show all versions installed"
  echo "    --minor    show minor versions installed"
  echo "    --tags     show tags of installed versions"
  echo "    --pyenv    show versions managed by pyenv"
  echo "    --sys      show system python version"
  echo "    --install  set pyenv globals and create symlinks (use in Dockerfile only)"
  echo "    --help     show this help and exit"
}

# main

main () {

  if [ "$#" = "0" ]; then
    py_usage
    exit 0
  elif [ "$#" = "1" ]; then
    SRC="py_versions"
  else
    SRC="echo $2"
  fi

  case $1 in
    --list)    py_versions | py_sort;;
    --minor)   $SRC | py_sort | py_minor;;
    --tags)    py_versions | py_sort | py_tag;;
    --pyenv)   py_pyenv | py_sort;;
    --sys)     py_sys;;
    --install) py_install;;
    --help)    py_usage;;
    *)
      echo "Unknown option:" $1
      exit 1
      ;;
  esac

  exit 0
}

main "$@"
