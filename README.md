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
| CPython 3.14.0a5 | free threaded | `py314t` | `python3.14t` | pyenv  |
| CPython 3.13.2   | free threaded | `py313t` | `python3.13t` | pyenv  |
| CPython 3.14.0a5 |               | `py314`  | `python3.14`  | pyenv  |
| CPython 3.13.2   | system ⚙️     | `py313`  | `python3.13`  | pyenv  |
| CPython 3.12.9   |               | `py312`  | `python3.12`  | pyenv  |
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
multipython 252D
```

<table>
<tr>
<td>

<!-- docsub: begin -->
<!-- docsub: exec cat tests/share/data/ls.txt | cut -d' ' -f3 -->
<!-- docsub: lines after 2 upto -1 -->
```shell
$ py ls -l
3.14.0a5t
3.13.2t
3.14.0a5
3.13.2
3.12.9
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
       py install [--sys TAG] [--no-update-info]
       py ls {--tag|--short|--long|--all}
       py root
       py sys
       py tag <PYTHON>
       py uninstall [--no-update-info]
       py --version
       py --help

commands:
  bin        Show Python executable command or path
  info       Extended details in JSON format
  install    Install system environment, commands, seed packages
  ls         List all distributions
  root       Show multipython root path
  sys        Show system python tag
  tag        Determine tag of executable
  uninstall  Uninstall system environment

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
  -c --cached       Show cached results
  --no-update-info  Don't update local info.json (works faster)
  --sys             Preferred system executable
  --version         Show multipython distribution version
  --help            Show this help and exit
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

* `base` – [tests/share/info/base.json@v252D](https://raw.githubusercontent.com/makukha/multipython/refs/tags/v252D/tests/share/info/base.json)
* `cpython` – [tests/share/info/cpython.json@v252D](https://raw.githubusercontent.com/makukha/multipython/refs/tags/v252D/tests/share/info/cpython.json)
* `latest` – [tests/share/info/latest.json@v252D](https://raw.githubusercontent.com/makukha/multipython/refs/tags/v252D/tests/share/info/latest.json)
* `supported` – [tests/share/info/supported.json@v252D](https://raw.githubusercontent.com/makukha/multipython/refs/tags/v252D/tests/share/info/supported.json)
* `unsafe` – [tests/share/info/unsafe.json@v252D](https://raw.githubusercontent.com/makukha/multipython/refs/tags/v252D/tests/share/info/unsafe.json)
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
    "version": "252D",
    "subset": "latest",
    "root": "/root/.multipython"
  },
  "pyenv": {
    "version": "2.5.3",
    "root": "/root/.pyenv",
    "python_versions": "/root/.pyenv/versions"
  },
  "tox": {
    "version": "4.24.1"
  },
  "uv": {
    "version": "0.5.31",
    "python_versions": "/root/.local/share/uv/python"
  },
  "virtualenv": {
    "version": "20.29.2",
    "config": "/root/.config/virtualenv/virtualenv.ini"
  },
  "system": {
    "tag": "py313",
    "root": "/root/.multipython/sys",
    "command": "python",
    "bin_dir": "/root/.multipython/sys/bin",
    "binary_path": "/root/.multipython/sys/bin/python",
    "packages": {
      "cachetools": "5.5.1",
      "chardet": "5.2.0",
      "colorama": "0.4.6",
      "distlib": "0.3.9",
      "filelock": "3.17.0",
      "packaging": "24.2",
      "pip": "25.0.1",
      "platformdirs": "4.3.6",
      "pluggy": "1.5.0",
      "pyproject-api": "1.9.0",
      "setuptools": "75.8.0",
      "tox": "4.24.1",
      "tox-multipython": "0.4.0",
      "virtualenv": "20.29.2",
      "virtualenv-multipython": "0.5.1",
      "wheel": "0.45.1"
    }
  },
  "base_image": {
    "name": "debian",
    "channel": "stable-slim",
    "digest": "sha256:5724d31208341cef9af6ae2be86be9cda6a87271f362a03481a522c9c19d401b"
  },
  "python": [
    {
      "version": "3.14.0a5t",
      "source": "pyenv",
      "tag": "py314t",
      "short": "3.14t",
      "command": "python3.14t",
      "bin_dir": "/root/.pyenv/versions/3.14.0a5t/bin",
      "binary_path": "/root/.pyenv/versions/3.14.0a5t/bin/python",
      "is_system": false,
      "packages": {
        "pip": "25.0.1",
        "setuptools": "75.8.0",
        "wheel": "0.45.1"
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
| `base` | 2.5.3 ✨ | 0.5.31 ✨ |
| *other images* | 2.5.3 ✨ | 0.5.31 ✨ |
<!-- docsub: end -->

## Derived images

<!-- docsub: begin -->
<!-- docsub: x package-versions derived -->
| Image tag | pip | setuptools | tox | virtualenv | wheel |
|---|---|---|---|---|---|
| `cpython` | 25.0.1 ✨ | 75.8.0 ✨ | 4.24.1 ✨ | 20.29.2 ✨ | 0.45.1 ✨ |
| `latest` | 25.0.1 ✨ | 75.8.0 ✨ | 4.24.1 ✨ | 20.29.2 ✨ | 0.45.1 ✨ |
| `supported` | 25.0.1 ✨ | 75.8.0 ✨ | 4.24.1 ✨ | 20.29.2 ✨ | 0.45.1 ✨ |
| `unsafe` | 25.0.1 ✨ | 75.8.0 ✨ | 4.5.1.1 | 20.21.1 | 0.45.1 ✨ |
<!-- docsub: end -->


## Single version images

<!-- docsub: begin -->
<!-- docsub: x package-versions single -->
| Image tag | pip | setuptools | tox | virtualenv | wheel |
|---|---|---|---|---|---|
| `py314t` | 25.0.1 ✨ | 75.8.0 ✨ | 4.24.1 ✨ | 20.29.2 ✨ | 0.45.1 ✨ |
| `py313t` | 25.0.1 ✨ | 75.8.0 ✨ | 4.24.1 ✨ | 20.29.2 ✨ | 0.45.1 ✨ |
| `py314` | 25.0.1 ✨ | 75.8.0 ✨ | 4.24.1 ✨ | 20.29.2 ✨ | 0.45.1 ✨ |
| `py313` | 25.0.1 ✨ | 75.8.0 ✨ | 4.24.1 ✨ | 20.29.2 ✨ | 0.45.1 ✨ |
| `py312` | 25.0.1 ✨ | 75.8.0 ✨ | 4.24.1 ✨ | 20.29.2 ✨ | 0.45.1 ✨ |
| `py311` | 25.0.1 ✨ | 75.8.0 ✨ | 4.24.1 ✨ | 20.29.2 ✨ | 0.45.1 ✨ |
| `py310` | 25.0.1 ✨ | 75.8.0 ✨ | 4.24.1 ✨ | 20.29.2 ✨ | 0.45.1 ✨ |
| `py39` | 25.0.1 ✨ | 75.8.0 ✨ | 4.24.1 ✨ | 20.29.2 ✨ | 0.45.1 ✨ |
| `py38` | 25.0.1 ✨ | 75.3.0 | 4.24.1 ✨ | 20.29.2 ✨ | 0.45.1 ✨ |
| `py37` | 24.0 | 68.0.0 | 4.8.0 | 20.26.6 | 0.42.0 |
| `py36` | 21.3.1 | 59.6.0 | 3.28.0 | 20.17.1 | 0.37.1 |
| `py35` | 20.3.4 | 50.3.2 | 3.28.0 | 20.15.1 | 0.37.1 |
| `py27` | 20.3.4 | 44.1.1 | 3.28.0 | 20.15.1 | 0.37.1 |
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
| `base-252D` | `sha256:091de4a2c046d9e17d972c90d709aa0ac9b3531dfc5f66c42293382774a0246f` |
| `cpython-252D` | `sha256:a67dbfe1fad182a83e0cf91bb882961624929b96f44abf9b7fc8c70c7e0031b1` |
| `py27-252D` | `sha256:957492d593cafa6d80c4f5b653cf5521cb46d61a989c73ea6e0af8f35614b4d8` |
| `py310-252D` | `sha256:a578c54fe5135c101f150d398844b76f507286129bf253689c0417a5980befc1` |
| `py311-252D` | `sha256:250b284d775b9d21d89372e6b045167216843f7a1afb758c5db2949bf3468ab0` |
| `py312-252D` | `sha256:44d73f34d31d30ec13a01c30e5e0e0f8f2d37322fa26794ca6d65667606afdf3` |
| `py313-252D` | `sha256:ad9b9759cb9bc36649a77aaa2f64ab9c7b0b8a97b74ae2c2d2735cb74d7c204c` |
| `py313t-252D` | `sha256:b2f433a85086e60df89630426ba113bcc98d9fac6d90bdd9c29f989d94543fd7` |
| `py314-252D` | `sha256:81fff7432462e15c9dcd55381fe6a8baa68c02e07aa168ef06fbaac417069f97` |
| `py314t-252D` | `sha256:c334ae77b51710008e150f043d2c6e8b021e4f1733fcbcaba141523c8487bf22` |
| `py35-252D` | `sha256:96ab4482164badc273752caae3a402d9663a34639f7d98d14f7ae475181519e2` |
| `py36-252D` | `sha256:e3bbbfedf59f80f74a2d7ef55f9753e3c65fc0f5cef1deae508ef2cb12569ed7` |
| `py37-252D` | `sha256:811c5b9e2dc1904334af3e04c0934a61b094cf60210ad91bc7f62d49e4d54ede` |
| `py38-252D` | `sha256:853aa94521454d6c9cfd2fee22b8dba952cb765772b180fe30527b992509c9d0` |
| `py39-252D` | `sha256:2bb16898c0c2816fe1787ea06945219069e4279b2c8ff3c5a252ee0e29193024` |
| `supported-252D` | `sha256:a3a30be836c1c2f74502f6ce1b077a8f393bc3a13994199184c84734f4ea320e` |
| `unsafe-252D` | `sha256:b5643aaa4abdbbc814a470def110b454b035b119a4f8ccd21ad5f9ae425d1453` |
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
