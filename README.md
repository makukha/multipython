# multipython 🐳<sup>🐍🐍</sup>

> Multi-version Python Docker image for testing and research.

[![GitHub Release](https://img.shields.io/github/v/tag/makukha/multipython?label=release)](https://github.com/makukha/multipython)
[![GitHub Release Date](https://img.shields.io/github/release-date/makukha/multipython?label=release%20date)](https://github.com/makukha/multipython)  
[![Docker Pulls](https://img.shields.io/docker/pulls/makukha/multipython)](https://hub.docker.com/r/makukha/multipython)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9755/badge)](https://www.bestpractices.dev/projects/9755)


# Features

* `makukha/multipython` — [pip](https://pip.pypa.io), [pyenv](https://github.com/pyenv/pyenv), [tox](https://tox.wiki), [uv](https://docs.astral.sh/uv), Python distributions
* `makukha/multipython:stable` — latest stable single version image
* `makukha/multipython:supported` — all [supported](https://devguide.python.org/versions) versions
* `makukha/multipython:{py314...}` — single version images
* [Build your own environment](#build-your-own-environment) from single version images
* Based on `debian:stable-slim`
* Single platform `linux/amd64`
* Tox env names match tag names, even non-standard `py313t`

## Python versions

### `makukha/multipython:latest`

| Distribution     | Note          | Tag      | Executable    | Source |
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

### `makukha/multipython:stable`

| Distribution     | Note          | Tag      | Executable    | Source |
|------------------|---------------|----------|---------------|--------|
| CPython 3.13.1   | system ⚙️     | `py313`  | `python3.13`  | pyenv  |

### `makukha/multipython:supported`

| Distribution     | Note          | Tag      | Executable    | Source |
|------------------|---------------|----------|---------------|--------|
| CPython 3.13.1   | free threaded | `py313t` | `python3.13t` | pyenv  |
| CPython 3.13.1   | system ⚙️     | `py313`  | `python3.13`  | pyenv  |
| CPython 3.12.8   |               | `py312`  | `python3.12`  | pyenv  |
| CPython 3.11.11  |               | `py311`  | `python3.11`  | pyenv  |
| CPython 3.10.16  |               | `py310`  | `python3.10`  | pyenv  |
| CPython 3.9.21   |               | `py39`   | `python3.9`   | pyenv  |

### Executables

All executables are on `PATH` as symlinks to respective distributions. System ⚙️ Python, that is always the latest stable version, is also available as simply `python`.

### Versions

* Check [Versions](#versions) section for [pyenv](https://github.com/pyenv/pyenv), [tox](https://tox.wiki), [uv](https://docs.astral.sh/uv), [pip](https://pip.pypa.io), [setuptools](https://setuptools.pypa.io) versions.

* See [Status of Python versions](https://devguide.python.org/versions) for the list of end-of-life versions.

### Distribution sources

The only used source used is [pyenv](https://github.com/pyenv/pyenv). However, it is planned to use [python-build-standalone](https://github.com/astral-sh/python-build-standalone) distributions for supported Python versions to speed up tests and image builds.

# Basic usage

```shell
docker pull makukha/multipython@latest
```

<!-- docsub after line 2: cat tests/test_readme_basic/tox.ini -->
```ini
# tox.ini

```

```shell
docker run --rm -v .:/test makukha/multipython tox run --root /test
```

> [!NOTE]
> Pay attention that tox env names match docker image single version tags, even non-standard free threaded `py313t` and `py314t`. This was made possible by custom virtualenv plugin [virtualenv-multipython](https://github.com/makukha/virtualenv-multipython).


# Advanced usage

## Build your own environment

Combine single version images to use a subset of Python distributions.

<!-- docsub after line 2: cat tests/test_readme_advanced/Dockerfile -->
```Dockerfile
# Dockerfile

```

## Helper utility `py`

`makukha/multipython` image comes with helper utility:

```shell
$ docker run --rm -it makukha/multipython
$ py version --sys
3.13.1
```

<table>
<tr>
<td>

<!-- docsub after line 1: sh tests/share/data/ls.txt | cut -d' ' -f3 -->
```shell
$ py ls
```
</td>
<td>

<!-- docsub after line 1: sh tests/share/data/ls.txt | cut -d' ' -f2 -->
```shell
$ py ls -s
```
</td>
<td>

<!-- docsub after line 1: sh tests/share/data/ls.txt | cut -d' ' -f1 -->
```shell
$ py ls -t
```
</td>
</tr>
</table>

<!-- docsub after line 1: cat tests/share/usage.txt -->
```shell
$ py --help
```

# Versions

## multipython release versioning

Starting from Jan 2025, this project uses [CalVer](https://calver.org) convention with [Date62](http://github.com/date62/date62-python)-based dates.

Version format is `YYMD[.P]`, where `YY` is `25,26,...`, `M` is HEX month (`1` = Jan, `A,B,C` = Oct, Nov, Dec), `D` is Base62-encoded day of month from `1` to `V` (31), `.P` is optional digital patch part if it will be needed to have multiple releases at the same day.

## Base tools

All released images share same versions of base tools, but [tox version](#tox-version) will vary depending on minimal Python version installed. The good news that it is selected automatically, even for custom images.

| Image tag | pyenv | uv      | tox       |
|-----------|-------|---------|-----------|
| `base`    | 2.5.0✨ | 0.5.14✨ | —         |
| Other     | 2.5.0✨ | 0.5.14✨ | *varying* |

<span>✨</span> latest version, will be updated in future releases.

## Python tools

Versions below are for system python distribution, symlinked to `python`.

<!-- docsub: cat docs/tab/package-versions.md -->
| Image tag   | pip    | setuptools | tox | virtualenv |
|-------------|--------|------------|-----|------------|

<span>✨</span> latest version, will be updated in future releases.

## tox version

The default tox version v4.5.1.1 is dictated by [virtualenv support](https://virtualenv.pypa.io/en/latest/changelog.html) of Python versions. Virtualenv v20.22 dropped support for Python 3.6, v20.27 dropped support of Python 3.7. Depending on minimal Python version used in custom environment, tox version will be automatically selected by `py install`.

| Min Python version | virtualenv  | tox     |
|--------------------|-------------|---------|
| `<3.7`             | `<20.22.0`  | `<4.6`  |
| `<3.8`             | `<20.27.0`  | `>=4.6` |
| `>=3.8`            | `>=20.27.0` | `>=4.6` |

## JSON metadata

All versions included, paths to sources, and some other info is available in JSON format to be used for reference and in dev pipelines.

### On Docker images

On every image `makukha/multipython:<tag>` for all tags, including `base`, at `/root/.multipython/info.json`.

### On custom Docker images

After running `py install` (see [instructions](#build-your-own-environment)), `/root/.multipython/info.json` is updated, so custom images also have real metadata.

### On GitHub

* `makukha/multipython:latest` – [tests/share/info/latest.json](https://github.com/makukha/multipython/blob/main/tests/share/info/latest.json)
* `makukha/multipython:stable` – [tests/share/info/stable.json](https://github.com/makukha/multipython/blob/main/tests/share/info/stable.json)
* `makukha/multipython:supported` – [tests/share/info/stable.json](https://github.com/makukha/multipython/blob/main/tests/share/info/supported.json)
* `makukha/multipython:base` – [tests/share/info/base.json](https://github.com/makukha/multipython/blob/main/tests/share/info/base.json)

### [Helper utility](#helper-utility-py) `py info`

```shell
docker run --rm makukha/multipython:latest py info -c
```

<!-- docsub: sh task run:latest -- py info -c | sed -ne '1,/    },/p' && echo '...' -->
```json
```

# Security

1. Check [vulnerability reports](https://hub.docker.com/r/makukha/multipython/tags) provided by Docker Scout.
2. Use specific [image digest](#image-digests).
3. Report security vulnerabilities via [GitHub Security Advisories](https://github.com/makukha/multipython/security/advisories).

Security vulnerabilities can come from

* Base [Debian image](https://hub.docker.com/_/debian/tags?name=stable-slim) `debian:stable-slim`
* Python distributions, especially [reached end-of-life](https://devguide.python.org/versions).
* multipython itself

## Image digests

<!-- docsub: cat docs/tab/image-digests.md -->
| Image tag | Digest |
|-----------|--------|


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

* To file bug report or feature request, please [create an issue](https://github.com/makukha/multipython/issues).
* To report security vulnerability, please use [GitHub Security Advisories](https://github.com/makukha/multipython/security/advisories).
* Want to contribute? Check [Contribution Guidelines](https://github.com/makukha/multipython/blob/main/.github/CONTRIBUTING.md).


# Changelog

Check repository [CHANGELOG.md](https://github.com/makukha/multipython/tree/main/CHANGELOG.md).
