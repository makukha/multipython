# multipython 🐳<sup>🐍🐍</sup>

> Multi-version Python Docker image for research and testing with tox.

[![GitHub Release](https://img.shields.io/github/v/tag/makukha/multipython?label=release)](https://github.com/makukha/multipython)
[![GitHub Release Date](https://img.shields.io/github/release-date/makukha/multipython?label=release%20date)](https://github.com/makukha/multipython)  
[![Docker Pulls](https://img.shields.io/docker/pulls/makukha/multipython)](https://hub.docker.com/r/makukha/multipython)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9755/badge)](https://www.bestpractices.dev/projects/9755)

# Features

<!-- docsub: begin -->
<!-- docsub: include docs/part/features.md -->
<!-- docsub: end -->


# Basic usage

<!-- docsub: begin -->
<!-- docsub: include docs/part/basic-usage.md -->
<!-- docsub: end -->


## Python versions

<!-- docsub: begin -->
<!-- docsub: include docs/part/python-versions.md -->
<!-- docsub: end -->


### Executables

All executables are on `PATH` as symlinks to respective distributions. System ⚙️ Python, that is always the latest stable version, is also available as simply `python`.

### Distribution sources

The only used source used is [pyenv](https://github.com/pyenv/pyenv). However, it is planned to use [python-build-standalone](https://github.com/astral-sh/python-build-standalone) distributions for supported Python versions to speed up tests and image builds.

### Versions

* Check [Versions](#versions) section for [pyenv](https://github.com/pyenv/pyenv), [tox](https://tox.wiki), [uv](https://docs.astral.sh/uv), [pip](https://pip.pypa.io), [setuptools](https://setuptools.pypa.io) versions.

* See [Status of Python versions](https://devguide.python.org/versions) for the list of end-of-life versions.


# Advanced usage

## Build your own environment

Combine single version images to use a subset of Python distributions.

<!-- docsub: begin -->
<!-- docsub: include tests/test_readme_advanced/Dockerfile -->
<!-- docsub: lines after 3 upto -1 -->
```Dockerfile
# Dockerfile

```
<!-- docsub: end -->

## CLI helper utility `py`

All `makukha/multipython` images come with helper utility

<!-- docsub: begin -->
<!-- docsub: exec docker run --rm makukha/multipython py sys -->
<!-- docsub: lines after 2 upto -1 -->
```shell
$ docker run --rm makukha/multipython py sys
3.13.1
```
<!-- docsub: end -->

<table>
<tr>
<td>

<!-- docsub: begin -->
<!-- docsub: exec cat tests/share/data/ls.txt | cut -d' ' -f3 -->
<!-- docsub: lines after 2 upto -1 -->
```shell
$ py ls -l
```
<!-- docsub: end -->
</td>
<td>

<!-- docsub: begin -->
<!-- docsub: exec cat tests/share/data/ls.txt | cut -d' ' -f2 -->
<!-- docsub: lines after 2 upto -1 -->
```shell
$ py ls -s
```
<!-- docsub: end -->
</td>
<td>

<!-- docsub: begin -->
<!-- docsub: exec cat tests/share/data/ls.txt | cut -d' ' -f1 -->
<!-- docsub: lines after 2 upto -1 -->
```shell
$ py ls -t
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
```
<!-- docsub: end -->

## JSON metadata

### Docker images

Every [image](https://hub.docker.com/r/makukha/multipython) has JSON metadata file `/root/.multipython/info.json`

### Custom images

After running `py install` in custom image Dockerfile, `/root/.multipython/info.json` is updated automatically.

### Sources

* `latest` – [tests/share/info/latest.json](https://github.com/makukha/multipython/blob/main/tests/share/info/latest.json)
* `stable` – [tests/share/info/stable.json](https://github.com/makukha/multipython/blob/main/tests/share/info/stable.json)
* `supported` – [tests/share/info/stable.json](https://github.com/makukha/multipython/blob/main/tests/share/info/supported.json)
* `base` – [tests/share/info/base.json](https://github.com/makukha/multipython/blob/main/tests/share/info/base.json)

### CLI `py info`

```shell
docker run --rm makukha/multipython:latest py info -c
```

<!-- docsub: begin -->
<!-- docsub: exec task run:latest -- py info -c | sed -ne '1,/    },/p' && echo '...' -->
<!-- docsub: lines after 1 upto -1 -->
```json
```
<!-- docsub: end -->


# Versions

## Base tools

All released images share same versions of base tools, but [tox version](#tox-version) will vary depending on minimal Python version installed. The good news that it is selected automatically, even for custom images.

| Image tag | pyenv | uv      | tox       |
|-----------|-------|---------|-----------|
| `base`    | 2.5.0✨ | 0.5.14✨ | —         |
| Other     | 2.5.0✨ | 0.5.14✨ | *varying* |

<span>✨</span> latest version, will be updated in future releases.

## Python packages

Versions below are for system python distribution, symlinked to `python`.

<!-- docsub: begin -->
<!-- docsub: include docs/tab/package-versions.md -->
<!-- docsub: lines after 2 -->
| Image tag   | pip    | setuptools | tox | virtualenv |
|-------------|--------|------------|-----|------------|
<!-- docsub: end -->

<span>✨</span> latest version, will be updated in future releases.

## tox version

The default tox version v4.5.1.1 is dictated by [virtualenv support](https://virtualenv.pypa.io/en/latest/changelog.html) of Python versions. Virtualenv v20.22 dropped support for Python 3.6, v20.27 dropped support of Python 3.7. Depending on minimal Python version used in custom environment, tox version will be automatically selected by `py install`.

| Min Python version | virtualenv  | tox     |
|--------------------|-------------|---------|
| `<3.7`             | `<20.22.0`  | `<4.6`  |
| `<3.8`             | `<20.27.0`  | `>=4.6` |
| `>=3.8`            | `>=20.27.0` | `>=4.6` |

## multipython versioning

Starting from Jan 2025, this project uses [CalVer](https://calver.org) convention with [Date62](http://github.com/date62/date62-python) based dates.

Release version format is `YYMD[.patch]`
* `YY` is `25,26,...`
* `M` is Base16 month (`1` = Jan, `A,B,C` = Oct, Nov, Dec)
* `D` is Base62 day of month (from `1` to `V` = 31)
* `.patch` is optional numerical suffix allowing multiple releases per day

# Security

1. Check [vulnerability reports](https://hub.docker.com/r/makukha/multipython/tags) provided by Docker Scout
2. Use specific [image digest](#image-digests)
3. Report security vulnerabilities via [GitHub Security Advisories](https://github.com/makukha/multipython/security/advisories)

Security vulnerabilities can come from

* Base [Debian image](https://hub.docker.com/_/debian/tags?name=stable-slim) `debian:stable-slim`
* Python distributions, especially [reached end-of-life](https://devguide.python.org/versions)
* multipython itself

## Image digests

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

<!-- docsub: begin -->
<!-- docsub: include docs/part/feedback.md -->
<!-- docsub: end -->


# Changelog

Check repository [CHANGELOG.md](https://github.com/makukha/multipython/tree/main/CHANGELOG.md)
