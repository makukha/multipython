# multipython 🐳<sup>🐍</sup>

> Pyenv-based Docker image of Python 2.7 to 3.14 (with optional free threading) for multi-distribution testing.

[![release](https://img.shields.io/github/v/tag/makukha/multipython?label=tag)](https://github.com/makukha/multipython)
[![Docker Pulls](https://img.shields.io/docker/pulls/makukha/multipython)](https://hub.docker.com/r/makukha/multipython)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9755/badge)](https://www.bestpractices.dev/projects/9755)


# Features

* `makukha/multipython` — [pyenv](https://github.com/pyenv/pyenv), [tox](https://tox.wiki), CPython distributions
* `makukha/multipython:pyXY` — single distribution images
* Dynamically linked
* [Build your own environment](#build-your-own-environment) with single version images
* Based on `debian:stable-slim`
* Single platform `linux/amd64`

## Distributions included

| distribution     | build details | tag      | executable    |
|------------------|---------------|----------|---------------|
| CPython 3.14.0a3 | free-threaded | `py314t` | `python3.14t` |
| CPython 3.13.1   | free-threaded | `py313t` | `python3.13t` |
| CPython 3.14.0a3 |               | `py314`  | `python3.14`  |
| CPython 3.13.1 ✅ |               | `py313`  | `python3.13`  |
| CPython 3.12.8   |               | `py312`  | `python3.12`  |
| CPython 3.11.11  |               | `py311`  | `python3.11`  |
| CPython 3.10.16  |               | `py310`  | `python3.10`  |
| CPython 3.9.21   |               | `py39`   | `python3.9`   |
| CPython 3.8.20   |               | `py38`   | `python3.8`   |
| CPython 3.7.17   |               | `py37`   | `python3.7`   |
| CPython 3.6.15   |               | `py36`   | `python3.6`   |
| CPython 3.5.10   |               | `py35`   | `python3.5`   |
| CPython 2.7.18   |               | `py27`   | `python2.7`   |

✅ Latest stable executable is on `PATH` as system `python`, including `pip`.

All executables are on `PATH` as symlinks to respective pyenv distributions.

## Versions

* [pyenv](https://github.com/pyenv/pyenv) 2.4.23 — latest
* [tox](https://tox.wiki) 4.5.1.1 — the last version that supports virtualenv 20.21.1
* [virtualenv](https://virtualenv.pypa.io/en/latest/) 20.21.1 — the last version that supports Python versions below 3.6


# Basic usage

```shell
docker pull makukha/multipython@latest
```

```ini
# tox.ini
[tox]
env_list = py{27,35,36,37,38,39,310,311,312,313,314,313t,314t}

[testenv]
command = python --version

[testenv:py313t]
base_python = python3.13t

[testenv:py314t]
base_python = python3.14t
```

```shell
docker run --rm -v .:/app makukha/multipython tox run --root /app
```


# Advanced usage

## Build your own environment

Combine single version images to use a subset of Python distributions.

```Dockerfile
# Dockerfile
FROM makukha/multipython:pyenv
RUN mkdir /root/.pyenv/versions
COPY --from=makukha/multipython:py27 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py35 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py312 /root/.pyenv/versions /root/.pyenv/versions/
RUN py install --sys py312 --tox
```
### Tox version

The default tox version 4.5.1.1 is dictated by [virtualenv support](https://virtualenv.pypa.io/en/latest/changelog.html) of Python versions. Depending on minimal Python version used in custom environment, tox version will be selected automatically in `py install`:

| Python  | virtualenv  | tox     |
|---------|-------------|---------|
| `>=2 `  | `<20.22.0`  | `<4.6`  |
| `>=3.7` | `<20.27.0`  | `>=4.6` |
| `>=3.8` | `>=20.27.0` | `>=4.6` |


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

```shell
$ py ls
2.7.18
3.5.10
3.6.15
3.7.17
3.8.20
3.9.21
3.10.16
3.11.11
3.12.8
3.13.1
3.13.1t
3.14.0a3
3.14.0a3t
```
</td>
<td>

```shell
$ py ls -s
2.7
3.5
3.6
3.7
3.8
3.9
3.10
3.11
3.12
3.13
3.13t
3.14
3.14t
```
</td>
<td>

```shell
$ py ls -n
27
35
36
37
38
39
310
311
312
313
313t
314
314t
```
</td>
<td>

```shell
$ py ls -t
py27
py35
py36
py37
py38
py39
py310
py311
py312
py313
py313t
py314
py314t
```
</td>
</tr>
</table>

```shell
$ py --help
usage: py ls [ -l | -s | -n | -t ]
       py version < --min | --max | --stable | --sys > [ -l | -s | -n ]
       py binary < --name | --path > <TAG>
       py install --sys <TAG> [--tox]
       py root
       py --help

commands:
  binary   Show path to Python binary
  install  Install optional packages and create symlinks
  ls       List all distributions
  root     Show multipython root path
  version  Show specific python version

version options:
  -l, --long   Full version without prefix, e.g. 3.3.3a1
  -s, --short  Short version without prefix, e.g. 3.3
  -n, --nodot  Short version without prefix and dots, e.g. 33
  -t, --tag    Python tag, e.g. py33, pp19
  --min        Lowest installed version
  --max        Highest installed version
  --stable     Highest release version
  --sys        System python version

other options:
  --tox   Install tox
  --help  Show this help and exit
```


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
