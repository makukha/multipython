#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail


MULTIPYTHON_ROOT=/root/.multipython

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source "$SCRIPT_DIR/cmd/.env"


usage () {
  echo "usage: py bin {--cmd|--dir|--path} [TAG]"
  echo "       py info [--cached]"
  echo "       py install [--sys TAG] [--no-update-info]"
  echo "       py ls {--tag|--short|--long|--all}"
  echo "       py root"
  echo "       py sys"
  echo "       py tag <PYTHON>"
  echo "       py uninstall [--no-update-info]"
  echo "       py --version"
  echo "       py --help"
  echo
  echo "commands:"
  echo "  bin        Show Python executable command or path"
  echo "  info       Extended details in JSON format"
  echo "  install    Install system environment, commands, seed packages"
  echo "  ls         List all distributions"
  echo "  root       Show multipython root path"
  echo "  sys        Show system python tag"
  echo "  tag        Determine tag of executable"
  echo "  uninstall  Uninstall system environment"
  echo
  echo "binary info formats:"
  echo "  -c --cmd   Command name, expected to be on PATH"
  echo "  -d --dir   Path to distribution bin directory"
  echo "  -p --path  Path to distribution binary"
  echo
  echo "version formats:"
  echo "  -t --tag    Python tag, e.g. py39, pp19"
  echo "  -s --short  Short version without prefix, e.g. 3.9"
  echo "  -l --long   Full version without prefix, e.g. 3.9.12"
  echo "  -a --all    Lines 'tag short long', e.g. 'py39 3.9 3.9.3'"
  echo
  echo "other options:"
  echo "  -c --cached  Show cached results"
  echo "  --sys        Preferred system executable"
  echo "  --version    Show multipython distribution version"
  echo "  --help       Show this help and exit"
}


if [ $# = 0 ]; then
  usage
else
  case $1 in
    bin)       shift; bash "$SCRIPT_DIR/cmd/bin.sh" "$@" ;;
    checkupd)  shift; bash "$SCRIPT_DIR/cmd/checkupd.sh" ;;  # internal, undocumented
    info)      shift; bash "$SCRIPT_DIR/cmd/info.sh" "$@" ;;
    install)   shift; bash "$SCRIPT_DIR/cmd/install.sh" "$@" ;;
    uninstall)   shift; bash "$SCRIPT_DIR/cmd/uninstall.sh" "$@" ;;
    ls)        shift; bash "$SCRIPT_DIR/cmd/ls.sh" "$@" ;;
    root)      printf "$MULTIPYTHON_ROOT\n" ;;
    sys)       shift; bash "$SCRIPT_DIR/cmd/tag.sh" python ;;
    tag)       shift; bash "$SCRIPT_DIR/cmd/tag.sh" "$@" ;;
    --version) echo "multipython $(cat "$MULTIPYTHON_VERSION")" ;;
    --help)    usage ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
fi
