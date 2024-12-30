# multipython 🐳<sup>🐍🐍</sup>

> Pyenv-based Docker image of Python 2.7 to 3.14 (including free threading) for multi-distribution testing.

[![release](https://img.shields.io/github/v/tag/makukha/multipython?label=tag)](https://github.com/makukha/multipython)
[![Docker Pulls](https://img.shields.io/docker/pulls/makukha/multipython)](https://hub.docker.com/r/makukha/multipython)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9755/badge)](https://www.bestpractices.dev/projects/9755)


# Features

* `makukha/multipython` — [pip](https://pip.pypa.io), [pyenv](https://github.com/pyenv/pyenv), [tox](https://tox.wiki), [uv](https://docs.astral.sh/uv), Python distributions
* `makukha/multipython:py...` — single version images
* [Build your own environment](#build-your-own-environment) from single version images
* Based on `debian:stable-slim`
* Single platform `linux/amd64`

## Python versions

| Distribution     | Note          | Tag      | Executable    | Source |
|------------------|---------------|----------|---------------|--------|
| CPython 3.14.0a3 | free threaded | `py314t` | `python3.14t` | pyenv  |
| CPython 3.13.1   | free threaded | `py313t` | `python3.13t` | pyenv  |
| CPython 3.14.0a3 |               | `py314`  | `python3.14`  | pyenv  |
| CPython 3.13.1   | ✅ system      | `py313`  | `python3.13`  | pyenv  |
| CPython 3.12.8   |               | `py312`  | `python3.12`  | pyenv  |
| CPython 3.11.11  |               | `py311`  | `python3.11`  | pyenv  |
| CPython 3.10.16  |               | `py310`  | `python3.10`  | pyenv  |
| CPython 3.9.21   |               | `py39`   | `python3.9`   | pyenv  |
| CPython 3.8.20   | EOL           | `py38`   | `python3.8`   | pyenv  |
| CPython 3.7.17   | EOL           | `py37`   | `python3.7`   | pyenv  |
| CPython 3.6.15   | EOL           | `py36`   | `python3.6`   | pyenv  |
| CPython 3.5.10   | EOL           | `py35`   | `python3.5`   | pyenv  |
| CPython 2.7.18   | EOL           | `py27`   | `python2.7`   | pyenv  |

### Executables

All executables are on `PATH` as symlinks to respective distributions. ✅ System Python, that is always the latest stable version, is also available as simply `python`.

### Versions

Check [Versions](#versions) section for [pyenv](https://github.com/pyenv/pyenv), [tox](https://tox.wiki), [uv](https://docs.astral.sh/uv), [pip](https://pip.pypa.io), [setuptools](https://setuptools.pypa.io) versions.

See [Status of Python versions](https://devguide.python.org/versions) for the list of end-of-life versions.

### Distribution sources

The only used source used is [pyenv](https://github.com/pyenv/pyenv). However, it is planned to use [python-build-standalone](https://github.com/astral-sh/python-build-standalone) distributions for supported Python versions to speed up image builds.

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

<!-- docsub after line 1: cat tests/shared/dist-long.txt -->
```shell
$ py ls
```
</td>
<td>

<!-- docsub after line 1: cat tests/shared/dist-short.txt -->
```shell
$ py ls -s
```
</td>
<td>

<!-- docsub after line 1: cat tests/shared/dist-tag.txt -->
```shell
$ py ls -t
```
</td>
</tr>
</table>

<!-- docsub after line 1: cat tests/shared/usage.txt -->
```shell
$ py --help
```

# Versions

## Base tools

All released images share same versions of base tools, but [tox version](#tox-version) will vary depending on minimal Python version installed. The good news that it is selected automatically, even for custom images.

| Image tag | pyenv  | uv      | tox       |
|-----------|--------|---------|-----------|
| `base`    | 2.5.0* | 0.5.13* | —         |
| Other     | 2.5.0* | 0.5.13* | *varying* |

<span>*</span> latest version, may be updated in future releases.

## Python tools

| Image tag | pip       | setuptools | tox, system wide |
|-----------|-----------|------------|------------------|
| `latest`  | *varying* | *varying*  | 4.5.1.1          |
| `base`    | —         | —          | —                |
| `py27`    | 20.3.4    | 44.1.1     |                  |
| `py35`    | 9.0.1     | 28.8.0     |                  |
| `py36`    | 21.3.1    | 59.6.0     |                  |
| `py37`    | 24.0      | 68.0.0     |                  |
| `py38`    | 24.3.1*   | 75.3.0     |                  |
| `py39`    | 24.3.1*   | 75.6.1*    |                  |
| `py310`   | 24.3.1*   | 75.6.1*    |                  |
| `py311`   | 24.3.1*   | 75.6.1*    |                  |
| `py312`   | 24.3.1*   | 75.6.1*    |                  |
| `py313`   | 24.3.1*   | 75.6.1*    |                  |
| `py313t`  | 24.3.1*   | 75.6.1*    |                  |
| `py314`   | 24.3.1*   | 75.6.1*    |                  |
| `py314t`  | 24.3.1*   | 75.6.1*    |                  |

<span>*</span> latest version, may be updated in future releases.

## tox version

The default tox version 4.5.1.1 is dictated by [virtualenv support](https://virtualenv.pypa.io/en/latest/changelog.html) of Python versions. Depending on minimal Python version used in custom environment, tox version will be automatically selected by `py install`:

| Python  | virtualenv  | tox     |
|---------|-------------|---------|
| `>=2 `  | `<20.22.0`  | `<4.6`  |
| `>=3.7` | `<20.27.0`  | `>=4.6` |
| `>=3.8` | `>=20.27.0` | `>=4.6` |

## JSON metadata

All versions included, paths to sources, and some other info is available in JSON format to be used for reference and in dev pipelines.

### On Docker images

On every image `makukha/multipython:latest`, `makukha/multipython:py...`, `makukha/multipython:base` at `/root/.multipython/info.json`.

### On custom Docker images

After running `py install` (see [instructions](#build-your-own-environment)).

### On GitHub

* `makukha/multipython:latest` – [makukha/multipython/info/latest.json](blob/main/latest.json)

### [Helper utility](#helper-utility-py) `py info`

```shell
docker run --rm makukha/multipython:latest py info -c
```

<!-- docsub: sh task run:latest -- py info -c | sed -ne '1,/    },/p' && echo '...' -->
```json
```

# Security

1. Check [vulnerability reports](https://hub.docker.com/r/makukha/multipython/tags) provided by Docker Scout.
2. Use specific [image digests](#image-digests) if necessary.
3. Report security vulnerabilities via [GitHub Security Advisories](https://github.com/makukha/multipython/security/advisories).

Security vulnerabilities can come from

* base [Debian image](https://hub.docker.com/_/debian/tags?name=stable-slim) `debian:stable-slim`
* Python distributions, especially [reached end-of-life](https://devguide.python.org/versions).
* multipython itself

## Image digests

> TODO


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

> TODO
