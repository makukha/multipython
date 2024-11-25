# multipython 🐳<sup>🐍<sup>🐍</sup></sup>

> Docker image with latest pyenv Python 2.7 to 3.14 for multi-version testing.

[![Docker Pulls](https://img.shields.io/docker/pulls/makukha/multipython)](https://hub.docker.com/r/makukha/multipython)

## Python versions

| Python implementation          | Executable    |
|--------------------------------|---------------|
| CPython 3.14.a2                | `python3.14`  |
| CPython 3.13.0, free threading | `python3.13t` |
| CPython 3.13.0<sup>1</sup>     | `python3.13`  |
| CPython 3.12.7                 | `python3.12`  |
| CPython 3.11.10                | `python3.11`  |
| CPython 3.10.15                | `python3.10`  |
| CPython 3.9.20                 | `python3.9`   |
| CPython 3.8.20                 | `python3.8`   |
| CPython 3.7.17                 | `python3.7`   |
| CPython 3.6.15                 | `python3.6`   |
| CPython 3.5.10                 | `python3.5`   |
| CPython 2.7.18                 | `python2.7`   |

<sup>1</sup> — Latest stable executable is not installed by pyenv but comes directly from [official Python image](https://hub.docker.com/layers/library/python/3.13.0-slim-bookworm/images/sha256-257a268975211849698b1a2c8e120aa8cd6600cef4fec8e995e36ec4090a0db8?context=explore) (this is also the base image).

All executables above are symlinks from `/usr/local/bin/pythonX.Y` to respective pyenv managed versions.

## Other versions

* [pyenv](https://github.com/pyenv/pyenv) — latest master as of image release date
* [tox](https://tox.wiki) 4.5.1.1 — the last version that supports virtualenv 20.21.1
* [virtualenv](https://virtualenv.pypa.io/en/latest/) 20.21.1 — the last version that supports Python versions below 3.6

# Usage

```shell
docker pull makukha/multipython
```

```ini
# tox.ini
[tox]
env_list = py{27,35,36,37,38,39,310,311,312,313,313t,314}
[testenv]
# ...
[testenv:py313t]
base_python = python3.13t
# ...
```

```yaml
# compose.yaml
services:
  tests:
    image: makukha/multipython:latest
    command: tox run
    volumes:
      # ...bind mount sources and tox.ini
```

```shell
docker compose run tests
```

# Alternatives

## GitHub Action [setup-python](https://github.com/actions/setup-python)

Supports all patch versions but [does not support Python 2.7](https://github.com/actions/setup-python/issues/672) and does not support free threaded 3.13 [at the moment](https://github.com/actions/setup-python/issues/771).

## [divio/multi-python](https://github.com/divio/multi-python)

Apt CPython 3.7 to 3.12 from deadsnakes PPA.

## [dhermes/python-multi](https://github.com/dhermes/python-multi)

pyenv CPython 3.8 to 3.12, PyPy 3.10.

## [vicamo/pyenv](https://hub.docker.com/r/vicamo/pyenv/tags)

Last updated 2 years ago.
