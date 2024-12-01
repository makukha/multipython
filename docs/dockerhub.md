[![GitHub Tag](https://img.shields.io/github/v/tag/makukha/multipython?label=GitHub%20Tag)](https://github.com/makukha/multipython)

[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9755/badge)](https://www.bestpractices.dev/projects/9755)

* Based on official `python3.13:slim-bookworm`
* `makukha/multipython` — [tox](https://tox.wiki) and most [pyenv](https://github.com/pyenv/pyenv) CPython versions
* `makukha/multipython:pyXY` — single version images
* [Build your own environment](https://github.com/makukha/multipython?tab=readme-ov-file#build-your-own-environment) with single version images


# Quick reference

* **Maintained by:** [Michael Makukha](https://github.com/makukha)
* **Where to get help:** [GitHub repository](https://github.com/makukha/multipython)
* **Where to file issues:** [GitHub issues](https://github.com/makukha/multipython/issues)
* **Supported architectures:** `amd64`


# Supported tags and respective `Dockerfile` links

* [`latest, 2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *all Python versions, pyenv, tox*
* [`pyenv, pyenv-2.4.19`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *pyenv 2.4.19, tox 4.5.1.1*
* [`py314t, py314t-2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 3.14.a2 free-threaded*
* [`py313t, py313t-2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 3.13.0 free-threaded*
* [`py314, py314-2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 3.14.a2*
* [`py313, py313-2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 3.13.0*
* [`py312, py312-2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 3.12.7*
* [`py311, py311-2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 3.11.10*
* [`py310, py310-2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 3.10.15*
* [`py39, py39-2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 3.9.20*
* [`py38, py38-2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 3.8.20*
* [`py37, py37-2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 3.7.17*
* [`py36, py36-2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 3.6.15*
* [`py35, py35-2024.12.1`](https://github.com/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 3.5.10*
* [`py27, py27-2024.12.1`](https://github.co-m/makukha/multipython/blob/v2024.12.1/Dockerfile) — *CPython 2.7.18*


Outdated releases remain in [Docker Registry](https://hub.docker.com/r/makukha/multipython/tags).


# How to use this image

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
$ py --sys
3.13.0
```

<table>
<tr>
<td>

```shell
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
