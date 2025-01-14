[![GitHub Release](https://img.shields.io/github/v/tag/makukha/multipython?label=release)](https://github.com/makukha/multipython)°[![GitHub Release Date](https://img.shields.io/github/release-date/makukha/multipython?label=release%20date)](https://github.com/makukha/multipython)°[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9755/badge)](https://www.bestpractices.dev/projects/9755)

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

# Quick reference

* **Supported architectures**: `amd64`
* **Maintained by**: [Michael Makukha](https://github.com/makukha)
* **Where to get help**: [GitHub repository](https://github.com/makukha/multipython)
* **Where to file issues**: [GitHub issues](https://github.com/makukha/multipython/issues)
* **Documentation**: [github.com/makukha/multipython](https://github.com/makukha/multipython)

# Supported tags and respective `Dockerfile` links

<!-- docsub: begin -->
<!-- docsub: include docs/part/image-tags.md -->
* [`latest, 251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *all supported and prerelease CPython versions*
* [`cpython, cpython-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.13.1 — latest version*
* [`supported, supported-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *all supported CPython versions*
* [`unsafe, unsafe-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *all CPython versions, including EOL*
* [`base, base-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *pyenv, uv*
* [`py314t, py314t-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.14.0a3 free-threaded*
* [`py313t, py313t-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.13.1 free-threaded*
* [`py314, py314-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.14.0a3*
* [`py313, py313-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.13.1*
* [`py312, py312-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.12.8*
* [`py311, py311-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.11.11*
* [`py310, py310-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.10.16*
* [`py39, py39-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.9.21*
* [`py38, py38-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.8.20*
* [`py37, py37-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.7.17*
* [`py36, py36-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.6.15*
* [`py35, py35-251E`](https://github.com/makukha/multipython/blob/v251E/Dockerfile) — *CPython 3.5.10*
* [`py27, py27-251E`](https://github.co-m/makukha/multipython/blob/v251E/Dockerfile) — *CPython 2.7.18*

All images with Python include pip, pyenv, tox, uv.
<!-- docsub: end -->

# How to use this image

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

See [Documentation](https://github.com/makukha/multipython?tab=readme-ov-file) for advanced usage.


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


# Documentation

* [Building your own](https://github.com/makukha/multipython?tab=readme-ov-file#build-your-own-environment) environment
* [Helper utility](https://github.com/makukha/multipython?tab=readme-ov-file#cli-helper-utility-py) usage
* [JSON metadata](https://github.com/makukha/multipython?tab=readme-ov-file#json-metadata) sources
* [Package versions](https://github.com/makukha/multipython?tab=readme-ov-file#python-packages) installed
* [Security](https://github.com/makukha/multipython?tab=readme-ov-file#security) measures

# Image digests

Use specific [image digests](https://github.com/makukha/multipython/tree/v2517#image-digests) for better control and reproducibility.

```shell
$ docker run --rm -v .:/src -w /src makukha/multipython@sha256:... tox run
```

# Feedback and contributing

<!-- docsub: begin -->
<!-- docsub: include docs/part/feedback.md -->
* To file bug report or feature request, please [create an issue](https://github.com/makukha/multipython/issues).
* To report security vulnerability, please use [GitHub Security Advisories](https://github.com/makukha/multipython/security/advisories).
* Want to contribute? Check [Contribution Guidelines](https://github.com/makukha/multipython/blob/main/.github/CONTRIBUTING.md).
<!-- docsub: end -->
