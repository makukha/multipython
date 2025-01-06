# multipython 🐳<sup>🐍🐍</sup>

> Multi-version Python Docker image for research and testing with tox.

[![GitHub Release](https://img.shields.io/github/v/tag/makukha/multipython?label=release)](https://github.com/makukha/multipython)
[![GitHub Release Date](https://img.shields.io/github/release-date/makukha/multipython?label=release%20date)](https://github.com/makukha/multipython)  
[![Docker Pulls](https://img.shields.io/docker/pulls/makukha/multipython)](https://hub.docker.com/r/makukha/multipython)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9755/badge)](https://www.bestpractices.dev/projects/9755)

# Features

<!-- docsub: begin -->
<!-- docsub: include docs/part/features.md -->
* `makukha/multipython` — [pip](https://pip.pypa.io), [pyenv](https://github.com/pyenv/pyenv), [tox](https://tox.wiki), [uv](https://docs.astral.sh/uv), Python distributions
* `makukha/multipython:stable` — latest stable single version image
* `makukha/multipython:supported` — all [supported](https://devguide.python.org/versions) versions
* `makukha/multipython:{py314...}` — single version images
* Tox env names match tag names, even non-standard `py313t`
* [Build your own environment](https://github.com/makukha/multipython#build-your-own-environment) from single version images
* Based on `debian:stable-slim`
* Single platform `linux/amd64`
<!-- docsub: end -->


# Basic usage

<!-- docsub: begin #readme -->
<!-- docsub: include docs/part/basic-usage.md -->
```shell
docker pull makukha/multipython@latest
```

<!-- docsub: begin -->
<!-- docsub: include tests/test_readme_basic/tox.ini -->
<!-- docsub: lines after 2 upto -1 -->
```ini
# tox.ini
[tox]
env_list = py{27,35,36,37,38,39,310,311,312,313,314,313t,314t}
[testenv]
command = {env_python} --version
```
<!-- docsub: end -->

```shell
docker run --rm -v .:/src makukha/multipython tox run --root /src
```

Single version images have tox installed and can be used on their own:
```shell
$ docker run --rm -v .:/src makukha/multipython:py38 tox run --root /src
```
<!-- docsub: end #readme -->


## Python versions

<!-- docsub: begin -->
<!-- docsub: include docs/part/python-versions.md -->
* `makukha/multipython:latest` —

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

* `makukha/multipython:stable` — `py313`
* `makukha/multipython:supported` — `py313t`, `py313`, `py312`, `py311`, `py310`, `py39`
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

<!-- docsub: begin -->
<!-- docsub: exec docker run --rm makukha/multipython py sys -->
<!-- docsub: lines after 2 upto -1 -->
```shell
$ docker run --rm makukha/multipython py sys
py313
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
       py ls {--long|--short|--tag|--all}
       py root
       py sys
       py --version
       py --help

commands:
  bin      Show Python executable command or path
  info     Extended details in JSON format
  install  Install optional packages and symlinks
  ls       List all distributions
  root     Show multipython root path
  sys      Show system python tag

binary info formats:
  -c --cmd   Command name, expected to be on PATH
  -d --dir   Path to distribution bin directory
  -p --path  Path to distribution binary

version formats:
  -l --long   Full version without prefix, e.g. 3.9.12
  -s --short  Short version without prefix, e.g. 3.9
  -t --tag    Python tag, e.g. py39, pp19
  -a --all    Lines 'tag short long', e.g. 'py39 3.9 3.9.3'

other options:
  -c --cached  Show cached results
  --version    Show multipython distribution version
  --help       Show this help and exit
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
{
  "multipython": {
    "version": "2513",
    "subset": "latest",
    "root": "/root/.multipython"
  },
  "pyenv": {
    "version": "2.5.0",
    "root": "/root/.pyenv",
    "python_versions": "/root/.pyenv/versions"
  },
  "tox": {
    "version": "4.5.1.1"
  },
  "uv": {
    "version": "0.5.14",
    "python_versions": "/root/.local/share/uv/python"
  },
  "virtualenv": {
    "version": "20.21.1"
  },
  "base_image": {
    "name": "debian",
    "channel": "stable-slim",
    "digest": "sha256:5f21ebd358442f40099c997a3f4db906a7b1bd872249e67559f55de654b55d3b"
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
        "setuptools": "75.6.0"
      }
    },
...
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
| Tag | pip | setuptools | tox | virtualenv |
|---|---|---|---|---|
| `latest` | 24.3.1 ✨ | 75.6.0 ✨ | 4.5.1.1 | 20.21.1 |
| `stable` | 24.3.1 ✨ | 75.6.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `supported` | 24.3.1 ✨ | 75.6.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `base` | — | — | — | — |
| `py314t` | 24.3.1 ✨ | 75.6.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py313t` | 24.3.1 ✨ | 75.6.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py314` | 24.3.1 ✨ | 75.6.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py313` | 24.3.1 ✨ | 75.6.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py312` | 24.3.1 ✨ | 75.6.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py311` | 24.3.1 ✨ | 75.6.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py310` | 24.3.1 ✨ | 75.6.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py39` | 24.3.1 ✨ | 75.6.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py38` | 24.3.1 ✨ | 75.3.0 | 4.23.2 ✨ | 20.28.1 ✨ |
| `py37` | 24.0 | 68.0.0 | 4.8.0 | 20.26.6 |
| `py36` | 21.3.1 | 59.6.0 | 3.28.0 | 20.17.1 |
| `py35` | 20.3.4 | 50.3.2 | 3.28.0 | 20.15.1 |
| `py27` | 20.3.4 | 44.1.1 | 3.28.0 | 20.15.1 |
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
* To file bug report or feature request, please [create an issue](https://github.com/makukha/multipython/issues).
* To report security vulnerability, please use [GitHub Security Advisories](https://github.com/makukha/multipython/security/advisories).
* Want to contribute? Check [Contribution Guidelines](https://github.com/makukha/multipython/blob/main/.github/CONTRIBUTING.md).
<!-- docsub: end -->


# Changelog

Check repository [CHANGELOG.md](https://github.com/makukha/multipython/tree/main/CHANGELOG.md)
