[![GitHub Tag](https://img.shields.io/github/v/tag/makukha/multipython?label=GitHub%20Tag)](https://github.com/makukha/multipython)

[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9755/badge)](https://www.bestpractices.dev/projects/9755)


* `makukha/multipython` — [pyenv](https://github.com/pyenv/pyenv), [tox](https://tox.wiki), CPython distributions
* `makukha/multipython:pyXY` — single version images
* [Build your own environment](https://github.com/makukha/multipython#build-your-own-environment) from single version images
* Based on `debian:stable-slim`
* Single platform `linux/amd64`


# Quick reference

* **Maintained by**: [Michael Makukha](https://github.com/makukha)
* **Where to get help**: [GitHub repository](https://github.com/makukha/multipython)
* **Where to file issues**: [GitHub issues](https://github.com/makukha/multipython/issues)
* **Supported architectures**: `amd64`


# Supported tags and respective `Dockerfile` links

* [`latest, 2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *all Python versions, pyenv, tox, uv*
* [`base, base-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *pyenv, tox, uv*
* [`py314t, py314t-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 3.14.0a3 free-threaded*
* [`py313t, py313t-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 3.13.1 free-threaded*
* [`py314, py314-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 3.14.0a3*
* [`py313, py313-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 3.13.1*
* [`py312, py312-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 3.12.8*
* [`py311, py311-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 3.11.11*
* [`py310, py310-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 3.10.16*
* [`py39, py39-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 3.9.21*
* [`py38, py38-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 3.8.20*
* [`py37, py37-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 3.7.17*
* [`py36, py36-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 3.6.15*
* [`py35, py35-2024.12.27`](https://github.com/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 3.5.10*
* [`py27, py27-2024.12.27`](https://github.co-m/makukha/multipython/blob/v2024.12.27/Dockerfile) — *CPython 2.7.18*

See [Versions](https://github.com/makukha/multipython#versions) of everything included in the `latest` image.


# How to use this image

```shell
docker pull makukha/multipython@latest
```

<!-- docsub after line 2: cat tests/test_readme_basic/tox.ini -->
```ini
# tox.ini

```

```shell
docker run --rm -v .:/app makukha/multipython tox run --root /app
```


# Advanced usage

## Build your own environment

Combine single version images to use a subset of Python distributions.

<!-- docsub: cat tests/test_readme_advanced/Dockerfile -->
```Dockerfile
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


# Feedback and contributing

* To file bug report or feature request, please [create an issue](https://github.com/makukha/multipython/issues).
* To report security vulnerability, please use [GitHub Security Advisories](https://github.com/makukha/multipython/security/advisories).
* Want to contribute? Check [Contribution Guidelines](https://github.com/makukha/multipython/blob/main/.github/CONTRIBUTING.md).
