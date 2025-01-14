# multipython 🐳<sup>🐍🐍</sup>

> Multi-version Python Docker image for research and testing with tox.

[![GitHub Release](https://img.shields.io/github/v/tag/makukha/multipython?label=release)](https://github.com/makukha/multipython)
[![GitHub Release Date](https://img.shields.io/github/release-date/makukha/multipython?label=release%20date)](https://github.com/makukha/multipython)
[![Docker Pulls](https://img.shields.io/docker/pulls/makukha/multipython)](https://hub.docker.com/r/makukha/multipython)
[![uses docsub](https://img.shields.io/badge/using-docsub-royalblue)](https://github.com/makukha/docsub)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9755/badge)](https://www.bestpractices.dev/projects/9755)

# Features

<!-- docsub: begin -->
<!-- docsub: include docs/part/features.md -->
* `makukha/multipython:latest` — prerelease and [supported](https://devguide.python.org/versions) Python distributions
* `makukha/multipython:cpython` — latest bugfix CPython image
* `makukha/multipython:supported` — [supported](https://devguide.python.org/versions) versions, not including prerelease
* `makukha/multipython:unsafe` — all versions, including end-of-life
* `makukha/multipython:{py314...}` — single version images
* All images except `base` have system Python in virtual environment
* All images include [pip](https://pip.pypa.io), [pyenv](https://github.com/pyenv/pyenv), [setuptools](https://setuptools.pypa.io), [tox](https://tox.wiki), [uv](https://docs.astral.sh/uv), [virtualenv](https://virtualenv.pypa.io)
* Tox and virtualenv understand multipython tag names, even non-standard `py313t`
* [Build your own environment](https://github.com/makukha/multipython#build-your-own-environment) from single version images
* Based on `debian:stable-slim`
* Single platform `linux/amd64`
<!-- docsub: end -->


# Basic usage

<!-- docsub: begin #readme -->
<!-- docsub: include docs/part/basic-usage.md -->
<!-- docsub: begin -->
<!-- docsub: include tests/test_readme_basic/tox.ini -->
<!-- docsub: lines after 2 upto -1 -->
```ini
# tox.ini
[tox]
env_list = py{27,35,36,37,38,39,310,311,312,313,314,313t,314t}
skip_missing_interpreters = false
[testenv]
command = {env_python} --version
```
<!-- docsub: end -->

```shell
docker run --rm -v .:/src -w /src makukha/multipython:unsafe tox run
```

Single version images can be used on their own:
```shell
$ docker run --rm -v .:/src -w /src makukha/multipython:py310 tox run
```
<!-- docsub: end #readme -->


## Python versions

<!-- docsub: begin -->
<!-- docsub: include docs/part/python-versions.md -->
| Distribution     | Note          | Tag      | Command       | Source |
|------------------|---------------|----------|---------------|--------|
| CPython 3.14.0a3 | free threaded | `py314t` | `python3.14t` | pyenv  |
| CPython 3.13.1   | free threaded | `py313t` | `python3.13t` | pyenv  |
| CPython 3.14.0a3 |               | `py314`  | `python3.14`  | pyenv  |
| CPython 3.13.1   | system ⚙️     | `py313`  | `python3.13`  | pyenv  |
| CPython 3.12.8   |               | `py312`  | `python3.12`  | pyenv  |
| CPython 3.11.11  |               | `py311`  | `python3.11`  | pyenv  |
| CPython 3.10.16  |               | `py310`  | `python3.10`  | pyenv  |
| CPython 3.9.21   |               | `py39`   | `python3.9`   | pyenv  |
| CPython 3.8.20   | EOL           | `py38`   | `python3.8`   | pyenv  |
| CPython 3.7.17   | EOL           | `py37`   | `python3.7`   | pyenv  |
| CPython 3.6.15   | EOL           | `py36`   | `python3.6`   | pyenv  |
| CPython 3.5.10   | EOL           | `py35`   | `python3.5`   | pyenv  |
| CPython 2.7.18   | EOL           | `py27`   | `python2.7`   | pyenv  |

* `makukha/multipython` — `py3{9,10,11,12,13,14}`, `py3{13,14}t`
* `makukha/multipython:cpython` — `py313`
* `makukha/multipython:supported` — `py3{9,10,11,12,13}`, `py313t`
* `makukha/multipython:unsafe` — all tags above
<!-- docsub: end -->


## Commands

All commands are on `PATH` as symlinks to respective distributions. System ⚙️ Python, that is always the latest bugfix version, is available as `python` in virtual environment along with `pip`, `tox`, and `virtualenv`.

## Distribution sources

The only used source used is [pyenv](https://github.com/pyenv/pyenv). However, it is planned to use [python-build-standalone](https://github.com/astral-sh/python-build-standalone) distributions for supported Python versions to speed up tests and image builds.

## Versions

* Check [Versions](#versions) section for [pyenv](https://github.com/pyenv/pyenv), [tox](https://tox.wiki), [uv](https://docs.astral.sh/uv), [pip](https://pip.pypa.io), [setuptools](https://setuptools.pypa.io) versions.

* See [Status of Python versions](https://devguide.python.org/versions) for the list of end-of-life versions.

## Tox and virtualenv

All single version tags above, including `py313t` and `py314t`, can be used as tox environment names (see example above) or as virtualenv python requests:
```shell
$ virtualenv --python py314t /tmp/venv
```

This is possible because two custom plugins are pre-installed in system environment (tox-multipython is installed only for tox 3). When building custom image, they are automatically added by `py install`. Both plugins are part of this project, and use multipython image for self testing.
* [virtualenv-multipython](https://github.com/makukha/virtualenv-multipython) — discovery plugin for virtualenv and tox 4
* [tox-multipython](https://github.com/makukha/tox-multipython) — discovery plugin for tox 3


# Advanced usage

## Build your own environment

Combine single version images to use a subset of Python distributions.

<!-- docsub: begin -->
<!-- docsub: include tests/test_readme_advanced/Dockerfile -->
<!-- docsub: lines after 2 upto -1 -->
```Dockerfile
# Dockerfile
FROM makukha/multipython:base
COPY --from=makukha/multipython:py27 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py35 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py312 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py313t /root/.pyenv/versions /root/.pyenv/versions/
RUN py install
```
<!-- docsub: end -->

## CLI helper utility `py`

All `makukha/multipython` images come with helper utility

```shell
$ docker run --rm makukha/multipython py --version
multipython 2517
```

<table>
<tr>
<td>

<!-- docsub: begin -->
<!-- docsub: exec cat tests/share/data/ls.txt | cut -d' ' -f3 -->
<!-- docsub: lines after 2 upto -1 -->
```shell
$ py ls -l
3.14.0a3t
3.13.1t
3.14.0a3
3.13.1
3.12.8
3.11.11
3.10.16
3.9.21
3.8.20
3.7.17
3.6.15
3.5.10
2.7.18
```
<!-- docsub: end -->
</td>
<td>

<!-- docsub: begin -->
<!-- docsub: exec cat tests/share/data/ls.txt | cut -d' ' -f2 -->
<!-- docsub: lines after 2 upto -1 -->
```shell
$ py ls -s
3.14t
3.13t
3.14
3.13
3.12
3.11
3.10
3.9
3.8
3.7
3.6
3.5
2.7
```
<!-- docsub: end -->
</td>
<td>

<!-- docsub: begin -->
<!-- docsub: exec cat tests/share/data/ls.txt | cut -d' ' -f1 -->
<!-- docsub: lines after 2 upto -1 -->
```shell
$ py ls -t
py314t
py313t
py314
py313
py312
py311
py310
py39
py38
py37
py36
py35
py27
```
<!-- docsub: end -->
</td>
</tr>
</table>

<!-- docsub: begin -->
<!-- docsub: include tests/share/usage.txt -->
<!-- docsub: lines after 2 upto -1 -->
```shell
$ py --help
usage: py bin {--cmd|--dir|--path} [TAG]
       py info [--cached]
       py install
       py ls {--tag|--short|--long|--all}
       py root
       py sys
       py tag <PYTHON>
       py --version
       py --help

commands:
  bin      Show Python executable command or path
  info     Extended details in JSON format
  install  Install sys environment, commands, and seed packages
  ls       List all distributions
  root     Show multipython root path
  sys      Show system python tag
  tag      Determine tag of executable

binary info formats:
  -c --cmd   Command name, expected to be on PATH
  -d --dir   Path to distribution bin directory
  -p --path  Path to distribution binary

version formats:
  -t --tag    Python tag, e.g. py39, pp19
  -s --short  Short version without prefix, e.g. 3.9
  -l --long   Full version without prefix, e.g. 3.9.12
  -a --all    Lines 'tag short long', e.g. 'py39 3.9 3.9.3'

other options:
  -c --cached  Show cached results
  --version    Show multipython distribution version
  --help       Show this help and exit
```
<!-- docsub: end -->

## JSON metadata

Every release has versions metadata in JSON format:

* inside release image as file
* inside custom images built from single versions
* in GitHub repository
* image CLI `py info -c`

### Release image

Every [image](https://hub.docker.com/r/makukha/multipython) has JSON metadata file `/root/.multipython/info.json`

### Custom image

After running `py install` in custom image Dockerfile, `/root/.multipython/info.json` is updated automatically.

### GitHub repository

* `base` – [tests/share/info/base.json@v2517](https://raw.githubusercontent.com/makukha/multipython/refs/tags/v2517/tests/share/info/base.json)
* `cpython` – [tests/share/info/cpython.json@v2517](https://raw.githubusercontent.com/makukha/multipython/refs/tags/v2517/tests/share/info/cpython.json)
* `latest` – [tests/share/info/latest.json@v2517](https://raw.githubusercontent.com/makukha/multipython/refs/tags/v2517/tests/share/info/latest.json)
* `supported` – [tests/share/info/supported.json@v2517](https://raw.githubusercontent.com/makukha/multipython/refs/tags/v2517/tests/share/info/supported.json)
* `unsafe` – [tests/share/info/unsafe.json@v2517](https://raw.githubusercontent.com/makukha/multipython/refs/tags/v2517/tests/share/info/unsafe.json)
* *(same for single version tags)*

### Image CLI `py info`

```shell
docker run --rm makukha/multipython:latest py info -c
```

<!-- docsub: begin -->
<!-- docsub: exec cat tests/share/info/latest.json | sed -ne '1,/    },/p' && echo '...' -->
<!-- docsub: lines after 1 upto -1 -->
```json
{
  "multipython": {
    "version": "251E",
    "subset": "latest",
    "root": "/root/.multipython"
  },
  "pyenv": {
    "version": "2.5.0",
    "root": "/root/.pyenv",
    "python_versions": "/root/.pyenv/versions"
  },
  "tox": {
    "version": "4.23.2"
  },
  "uv": {
    "version": "0.5.18",
    "python_versions": "/root/.local/share/uv/python"
  },
  "virtualenv": {
    "version": "20.28.1",
    "config": "/root/.config/virtualenv/virtualenv.ini"
  },
  "system": {
    "tag": "py313",
    "root": "/root/.multipython/sys",
    "command": "python",
    "bin_dir": "/root/.multipython/sys/bin",
    "binary_path": "/root/.multipython/sys/bin/python",
    "packages": {
      "cachetools": "5.5.0",
      "chardet": "5.2.0",
      "colorama": "0.4.6",
      "distlib": "0.3.9",
      "filelock": "3.16.1",
      "packaging": "24.2",
      "pip": "24.3.1",
      "platformdirs": "4.3.6",
      "pluggy": "1.5.0",
      "pyproject-api": "1.8.0",
      "setuptools": "75.8.0",
      "tox": "4.23.2",
      "virtualenv": "20.28.1",
      "virtualenv-multipython": "0.3.1"
    }
  },
  "base_image": {
    "name": "debian",
    "channel": "stable-slim",
    "digest": "sha256:b5ace515e78743215a1b101a6f17e59ed74b17132139ca3af3c37e605205e973"
  },
  "python": [
    {
      "version": "3.14.0a3t",
      "source": "pyenv",
      "tag": "py314t",
      "short": "3.14t",
      "command": "python3.14t",
      "bin_dir": "/root/.pyenv/versions/3.14.0a3t/bin",
      "binary_path": "/root/.pyenv/versions/3.14.0a3t/bin/python",
      "is_system": false,
      "packages": {
        "pip": "24.3.1",
        "setuptools": "75.8.0"
      }
    },
...
```
<!-- docsub: end -->


# Versions

Tools available in `base` image have (no surprise) the same versions in all other images. For Python package versions, `system` environment is used.

✨ latest versions will be updated in upcoming releases.

## Base image

<!-- docsub: begin -->
<!-- docsub: x package-versions base -->
| Image tag | pyenv | uv |
|---|---|---|
| `base` | 2.5.0 ✨ | 0.5.18 ✨ |
| *other images* | 2.5.0 ✨ | 0.5.18 ✨ |
<!-- docsub: end -->

## Derived images

<!-- docsub: begin -->
<!-- docsub: x package-versions derived -->
| Image tag | pip | setuptools | tox | virtualenv |
|---|---|---|---|---|
| `cpython` | 24.3.1 ✨ | 75.8.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `latest` | 24.3.1 ✨ | 75.8.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `supported` | 24.3.1 ✨ | 75.8.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `unsafe` | 24.3.1 ✨ | 75.8.0 ✨ | 4.5.1.1 | 20.21.1 |
<!-- docsub: end -->


## Single version images

<!-- docsub: begin -->
<!-- docsub: x package-versions single -->
| Image tag | pip | setuptools | tox | virtualenv |
|---|---|---|---|---|
| `py314t` | 24.3.1 ✨ | 75.8.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py313t` | 24.3.1 ✨ | 75.8.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py314` | 24.3.1 ✨ | 75.8.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py313` | 24.3.1 ✨ | 75.8.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py312` | 24.3.1 ✨ | 75.8.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py311` | 24.3.1 ✨ | 75.8.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py310` | 24.3.1 ✨ | 75.8.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py39` | 24.3.1 ✨ | 75.8.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py38` | 24.3.1 ✨ | 75.3.0 | 4.23.2 ✨ | 20.28.1 ✨ |
| `py37` | 24.0 | 68.0.0 | 4.8.0 | 20.26.6 |
| `py36` | 21.3.1 | 59.6.0 | 3.28.0 | 20.17.1 |
| `py35` | 20.3.4 | 50.3.2 | 3.28.0 | 20.15.1 |
| `py27` | 20.3.4 | 44.1.1 | 3.28.0 | 20.15.1 |
<!-- docsub: end -->

## Tox version

The minimal tox version v4.5.1.1 is dictated by [virtualenv support](https://virtualenv.pypa.io/en/latest/changelog.html) of Python versions. Virtualenv v20.22 dropped support for Python 3.6, v20.27 dropped support of Python 3.7. Depending on minimal Python version used in custom environment, tox version will be automatically selected by `py install`.

| Min Python version | virtualenv | tox     |
|--------------------|------------|---------|
| `<3.7`             | `<20.22`   | `<4.6`  |
| `<3.8`             | `<20.27`   | `>=4.6` |
| `>=3.8`            | `>=20.27`  | `>=4.6` |

# Project versioning

Starting from Jan 2025, multipython uses [CalVer](https://calver.org) convention with [Date62](http://github.com/date62/date62-python) based dates.

Release version format is `YYMD[.patch]`
* `YY` is `25,26,...`
* `M` is Base16 month (`1` = Jan, `A,B,C` = Oct, Nov, Dec)
* `D` is Base62 day of month (from `1` to `V` = 31)
* `.patch` is optional numerical suffix allowing multiple releases per day

# Testing

* All non-single-version targets and `py` helper tool are tested (see `/tests` directory for details).
* Source files are linted with [Hadolint](https://github.com/hadolint/hadolint) and [ShellCheck](https://www.shellcheck.net).

# Security

1. Check [vulnerability reports](https://hub.docker.com/r/makukha/multipython/tags) provided by Docker Scout
2. Use specific [image digest](https://hub.docker.com/r/makukha/multipython)
3. Report security vulnerabilities via [GitHub Security Advisories](https://github.com/makukha/multipython/security/advisories)

Security vulnerabilities can come from

* Base [Debian image](https://hub.docker.com/_/debian/tags?name=stable-slim) `debian:stable-slim`
* Python distributions, especially [reached end-of-life](https://devguide.python.org/versions)
* multipython itself

## Image digests

```shell
$ docker run --rm -v .:/src -w /src makukha/multipython@sha256:... tox run
```

<!-- docsub: begin -->
<!-- docsub: x image-digests -->
<!-- docsub: lines after 2 -->
| Image tag | Image digest |
|---|---|
| `base-251E` | `sha256:0576dd4a6ae6c1f6b78bd03e50a61d1b52c825b9aea4dff668d5b8c95fe1094e` |
| `cpython-251E` | `sha256:db00affc41d93becaebd2a4cc1382ddd254fdcf0768b769d30889af2da329eea` |
| `py27-251E` | `sha256:b1300fb67a26f6622e1c5f6ae7bf2e21e81cc69e49c4e17808db452073f63829` |
| `py310-251E` | `sha256:db520c2205fcc06dbc8e79e57cfbcaac76519a5df4f7a9ab91090fe07fda1b71` |
| `py311-251E` | `sha256:c1ecdca49a3592350fee7d20919237374cb5184fc1b07e8a49f261fdae5512b1` |
| `py312-251E` | `sha256:0a6804455d98a5cd474a504036dcc781d1c8f793c5f76aa60683e1fc7fba67ba` |
| `py313-251E` | `sha256:33dbd5a64448807719f51712b736a50f14c4383a9372c24e0945227b15a2d654` |
| `py313t-251E` | `sha256:7d149437e24f357e9b0409812e37e38593eae934c827aceb5e8073e72c6a20d9` |
| `py314-251E` | `sha256:14a95f46ae0024d33caebd755ec9b3c4120f3ecb884eb24938784d5ac45ce1ec` |
| `py314t-251E` | `sha256:59a0a9d29219a91108f4f11dfe605769ef28c5e06b5eb9f344155799fee56893` |
| `py35-251E` | `sha256:50bb600a106edcf7d8c8913a8a0ffe94530d0d9c0cf30c8be519a4920a88b646` |
| `py36-251E` | `sha256:4c13b44987d6dbe0b1225a90495c84a3c766f6a7b48801b1130ab596bcd589ca` |
| `py37-251E` | `sha256:9bb0cb5e1743b866bfb524b07464c94f638994b328835f4d3e66e1cb4da758b1` |
| `py38-251E` | `sha256:29d6fb9da0d4ca0d0a95669cdbd36c275153a3db666fe53edae7f03551ab9699` |
| `py39-251E` | `sha256:381a89082ccdb2e08d4130ff3e39db6c46c75bcb00c85524fc76d6c01f2b7e0a` |
| `supported-251E` | `sha256:b09762008d72150230c5f3c964d2680a615246eb13f39eb87a98a8e4d7be2830` |
| `unsafe-251E` | `sha256:9dad116083a8b0c1482c4f755340ae07a4d024d9e51a1a504d77b009749ebc87` |
<!-- docsub: end -->


# Alternatives

* **GitHub Action [setup-python](https://github.com/actions/setup-python)**
    * Supports all patch versions but [does not support Python 2.7](https://github.com/actions/setup-python/issues/672) and does not support free threaded 3.13 [at the moment](https://github.com/actions/setup-python/issues/771).

* **[divio/multi-python](https://github.com/divio/multi-python)**
    * Apt CPython 3.7 to 3.12 from deadsnakes PPA.

* **[dhermes/python-multi](https://github.com/dhermes/python-multi)**
    * pyenv CPython 3.8 to 3.12, PyPy 3.10.

* **[vicamo/pyenv](https://hub.docker.com/r/vicamo/pyenv/tags)**
    * Lacks recent versions


# Feedback and contributing

<!-- docsub: begin -->
<!-- docsub: include docs/part/feedback.md -->
* To file bug report or feature request, please [create an issue](https://github.com/makukha/multipython/issues).
* To report security vulnerability, please use [GitHub Security Advisories](https://github.com/makukha/multipython/security/advisories).
* Want to contribute? Check [Contribution Guidelines](https://github.com/makukha/multipython/blob/main/.github/CONTRIBUTING.md).
<!-- docsub: end -->


# Changelog

Check repository [CHANGELOG.md](https://github.com/makukha/multipython/tree/main/CHANGELOG.md)
