# multipython 🐳<sup>🐍</sup>

> Docker image with latest pyenv Python 2.7 to 3.14 for multi-version testing.

[![Docker Pulls](https://img.shields.io/docker/pulls/makukha/multipython)](https://hub.docker.com/r/makukha/multipython)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9755/badge)](https://www.bestpractices.dev/projects/9755)


# Features

* Based on official `python3.13:slim-bookworm`✅
* `makukha/multipython` — [tox](https://tox.wiki) and most [pyenv](https://github.com/pyenv/pyenv) CPython versions
* `makukha/multipython:pyXY` — single version images
* [Build your own environment](#build-your-own-environment) with single version images

## Python versions

| implementation                | executable    | single version tag |
|-------------------------------|---------------|--------------------|
| CPython 3.14.a2 free-threaded | `python3.14t` | `py314t`           |
| CPython 3.13.0 free-threaded  | `python3.13t` | `py313t`           |
| CPython 3.14.a2               | `python3.14`  | `py314`            |
| CPython 3.13.0 ✅             | `python3.13`  | `py313`            |
| CPython 3.12.7                | `python3.12`  | `py312`            |
| CPython 3.11.10               | `python3.11`  | `py311`            |
| CPython 3.10.15               | `python3.10`  | `py310`            |
| CPython 3.9.20                | `python3.9`   | `py39`             |
| CPython 3.8.20                | `python3.8`   | `py38`             |
| CPython 3.7.17                | `python3.7`   | `py37`             |
| CPython 3.6.15                | `python3.6`   | `py36`             |
| CPython 3.5.10                | `python3.5`   | `py35`             |
| CPython 2.7.18                | `python2.7`   | `py27`             |

✅ Latest stable executable is not installed by pyenv. It comes from base [official Python image](https://hub.docker.com/_/python).

All executables above are symlinks from `/usr/local/bin/pythonX.Y` to respective pyenv managed versions.

## Other versions

* [pyenv](https://github.com/pyenv/pyenv) 2.4.19 — latest as of image release date
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
# ...
[testenv:py313t]
base_python = python3.13t
[testenv:py314t]
base_python = python3.14t
# ...
```

```shell
docker run --rm -v .:/app makukha/multipython tox run --root /app
```


# Advanced usage

## Helper utility `py`

```shell
$ docker run --rm -it makukha/multipython
# in container
$ py --sys
3.13.0
```

<table>
<tr>
<td>

```shell
# in container
$ py --list
2.7.18
3.5.10
3.6.15
3.7.17
3.8.20
3.9.20
3.10.15
3.11.10
3.12.7
3.13.0
3.13.0t
3.14.0a2
3.14.0a2t
```
</td>
<td>

```shell
# in container
$ py --minor
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
# in container
$ py --tags
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
# in container
$ py --help
Usage: py <option>

  Multipython helper utility.

Options:
  --list   Show all versions installed
  --minor  Show minor versions installed
  --tags   Show tags of versions installed
  --pyenv  Show versions managed by pyenv
  --sys    Show version of system python
  --help   Show this help and exit

Other options:
  --install   Set pyenv globals and symlink (use in Dockerfile only)
  --to-minor  Convert full version from stdin/arg to minor format
  --to-tag    Convert full version from stdin/arg to tag format
```

## Build your own environment

To build custom image with subset of Python versions, use single version images.

The pre-installed tox version 4.5.1.1 is dictated by [virtualenv support](https://virtualenv.pypa.io/en/latest/changelog.html) of Python versions.

### Tox version compatibility

| virtualenv | dropped support | last compatible tox version |
|------------|-----------------|-----------------------------|
| 20.27.0    | Python 3.7      | latest                      |
| 20.22.0    | Python <=3.6    | 4.5.1.1                     |

This table may eventually run out of date, please always check [virtualenv changelog](https://virtualenv.pypa.io/en/latest/changelog.html).

### With pre-installed tox

Pre-installed tox (version 4.5.1.1) is required to use all available Python versions.

```Dockerfile
# Dockerfile
FROM makukha/multipython:pyenv
RUN mkdir /root/.pyenv/versions
COPY --from=makukha/multipython:py27 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py35 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py36 /root/.pyenv/versions /root/.pyenv/versions/
RUN py --install
```

### With latest tox, Python 3.7+

```Dockerfile
# Dockerfile
FROM makukha/multipython:pyenv
RUN mkdir /root/.pyenv/versions
COPY --from=makukha/multipython:py37 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py314 /root/.pyenv/versions /root/.pyenv/versions/
# set global pyenv versions and create symlinks
RUN py --install
# pin virtualenv to support Python 3.7
RUN pip install "virtualenv<20.27" tox
```

### With latest tox, Python 3.8+

```Dockerfile
# Dockerfile
FROM makukha/multipython:pyenv
RUN mkdir /root/.pyenv/versions
COPY --from=makukha/multipython:py312 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py313 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py314 /root/.pyenv/versions /root/.pyenv/versions/
# set global pyenv versions and create symlinks
RUN py --install
# use latest
RUN pip install tox
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
