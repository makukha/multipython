# multipython 🐳<sup>🐍🐍</sup>

> Multi-version Python Docker image for research and testing with tox.

[![GitHub Release](https://img.shields.io/github/v/tag/makukha/multipython?label=release)](https://github.com/makukha/multipython)
[![GitHub Release Date](https://img.shields.io/github/release-date/makukha/multipython?label=release%20date)](https://github.com/makukha/multipython)  
[![Docker Pulls](https://img.shields.io/docker/pulls/makukha/multipython)](https://hub.docker.com/r/makukha/multipython)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9755/badge)](https://www.bestpractices.dev/projects/9755)

# Features

<!-- docsub: begin -->
<!-- docsub: include docs/part/features.md -->
* `makukha/multipython` — prerelease and [supported](https://devguide.python.org/versions) Python distributions
* `makukha/multipython:cpython` — latest bugfix CPython image
* `makukha/multipython:supported` — [supported](https://devguide.python.org/versions) versions, not including prerelease
* `makukha/multipython:unsafe` — all versions, including end-of-life
* `makukha/multipython:{py314...}` — single version images
* All images include [pip](https://pip.pypa.io), [pyenv](https://github.com/pyenv/pyenv), [tox](https://tox.wiki), [uv](https://docs.astral.sh/uv)
* Tox env names match tag names, even non-standard `py313t`
* [Build your own environment](https://github.com/makukha/multipython#build-your-own-environment) from single version images
* Based on `debian:stable-slim`
* Single platform `linux/amd64`
<!-- docsub: end -->


# Basic usage

<!-- docsub: begin #readme -->
<!-- docsub: include docs/part/basic-usage.md -->
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
docker run --rm -v .:/src -w /src makukha/multipython:unsafe tox run
```

Single version images can be used on their own:
```shell
$ docker run --rm -v .:/src -w /src makukha/multipython:py310 tox run
```
<!-- docsub: end #readme -->


# Python versions

<!-- docsub: begin -->
<!-- docsub: include docs/part/python-versions.md -->
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

* `makukha/multipython` — `py3{9,10,11,12,13,14}`, `py3{13,14}t`
* `makukha/multipython:cpython` — `py313`
* `makukha/multipython:supported` — `py3{9,10,11,12,13}`, `py313t`
* `makukha/multipython:unsafe` — all tags above
<!-- docsub: end -->


### Executables

All executables are on `PATH` as symlinks to respective distributions. System ⚙️ Python, that is always the latest bugfix version, is also available as `python`.

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

```shell
$ docker run --rm makukha/multipython py --version
multipython 2517
```

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
       py tag <EXECUTABLE>
       py --version
       py --help

commands:
  bin      Show Python executable command or path
  info     Extended details in JSON format
  install  Install optional packages and symlinks
  ls       List all distributions
  root     Show multipython root path
  sys      Show system python tag
  tag      Determine tag of executable

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

Every release has versions metadata in JSON format:

* inside release image as file
* inside custom images built from single versions
* in GitHub repository
* image CLI `py info -c`

### Release image

Every [image](https://hub.docker.com/r/makukha/multipython) has JSON metadata file `/root/.multipython/info.json`

### Custom image

After running `py install` in custom image Dockerfile, `/root/.multipython/info.json` is updated automatically.

### GitHub repository

* `latest` – [tests/share/info/latest.json](https://github.com/makukha/multipython/blob/main/tests/share/info/latest.json)
* `cpython` – [tests/share/info/cpython.json](https://github.com/makukha/multipython/blob/main/tests/share/info/cpython.json)
* `supported` – [tests/share/info/supported.json](https://github.com/makukha/multipython/blob/main/tests/share/info/supported.json)
* `unsafe` – [tests/share/info/unsafe.json](https://github.com/makukha/multipython/blob/main/tests/share/info/unsafe.json)
* `base` – [tests/share/info/base.json](https://github.com/makukha/multipython/blob/main/tests/share/info/base.json)

### Image CLI `py info`

```shell
docker run --rm makukha/multipython:latest py info -c
```

<!-- docsub: begin -->
<!-- docsub: exec cat tests/share/info/latest.json | sed -ne '1,/    },/p' && echo '...' -->
<!-- docsub: lines after 1 upto -1 -->
```json
{
  "multipython": {
    "version": "2517",
    "subset": "latest",
    "root": "/root/.multipython"
  },
  "pyenv": {
    "version": "2.5.0",
    "root": "/root/.pyenv",
    "python_versions": "/root/.pyenv/versions"
  },
  "tox": {
    "version": "4.23.2"
  },
  "uv": {
    "version": "0.5.15",
    "python_versions": "/root/.local/share/uv/python"
  },
  "virtualenv": {
    "version": "20.28.1"
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
        "setuptools": "75.7.0"
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
| `base`    | 2.5.0✨ | 0.5.15✨ | —         |
| Other     | 2.5.0✨ | 0.5.15✨ | *varying* |

<span>✨</span> latest version, will be updated in upcoming releases.

## Python packages

Versions below are for system python distribution, symlinked to `python`.

<!-- docsub: begin -->
<!-- docsub: include docs/gen/package-versions.md -->
<!-- docsub: lines after 2 -->
| Image tag   | pip    | setuptools | tox | virtualenv |
|-------------|--------|------------|-----|------------|
| Tag | pip | setuptools | tox | virtualenv |
|---|---|---|---|---|
| `latest` | 24.3.1 ✨ | 75.7.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `cpython` | 24.3.1 ✨ | 75.7.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `supported` | 24.3.1 ✨ | 75.7.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `unsafe` | 24.3.1 ✨ | 75.7.0 ✨ | 4.5.1.1 | 20.21.1 |
| `base` | — | — | — | — |
| `py314t` | 24.3.1 ✨ | 75.7.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py313t` | 24.3.1 ✨ | 75.7.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py314` | 24.3.1 ✨ | 75.7.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py313` | 24.3.1 ✨ | 75.7.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py312` | 24.3.1 ✨ | 75.7.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py311` | 24.3.1 ✨ | 75.7.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py310` | 24.3.1 ✨ | 75.7.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py39` | 24.3.1 ✨ | 75.7.0 ✨ | 4.23.2 ✨ | 20.28.1 ✨ |
| `py38` | 24.3.1 ✨ | 75.3.0 | 4.23.2 ✨ | 20.28.1 ✨ |
| `py37` | 24.0 | 68.0.0 | 4.8.0 | 20.26.6 |
| `py36` | 21.3.1 | 59.6.0 | 3.28.0 | 20.17.1 |
| `py35` | 20.3.4 | 50.3.2 | 3.28.0 | 20.15.1 |
| `py27` | 20.3.4 | 44.1.1 | 3.28.0 | 20.15.1 |
<!-- docsub: end -->

<span>✨</span> latest version, will be updated in upcoming releases.

## tox version

The minimal tox version v4.5.1.1 is dictated by [virtualenv support](https://virtualenv.pypa.io/en/latest/changelog.html) of Python versions. Virtualenv v20.22 dropped support for Python 3.6, v20.27 dropped support of Python 3.7. Depending on minimal Python version used in custom environment, tox version will be automatically selected by `py install`.

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

# Testing

* All non-single-version targets and `py` helper tool are tested (see `/tests` directory for details).
* Source files are linted with [Hadolint](https://github.com/hadolint/hadolint) and [ShellCheck](https://www.shellcheck.net).

# Security

1. Check [vulnerability reports](https://hub.docker.com/r/makukha/multipython/tags) provided by Docker Scout
2. Use specific [image digest](https://hub.docker.com/r/makukha/multipython)
3. Report security vulnerabilities via [GitHub Security Advisories](https://github.com/makukha/multipython/security/advisories)

Security vulnerabilities can come from

* Base [Debian image](https://hub.docker.com/_/debian/tags?name=stable-slim) `debian:stable-slim`
* Python distributions, especially [reached end-of-life](https://devguide.python.org/versions)
* multipython itself

## Image digests

Use image digests for 100% reproducible results.

```shell
$ docker run --rm -v .:/src -w /src makukha/multipython@sha256:... tox run
```

<!-- docsub: begin -->
<!-- docsub: exec awk '{print $1" 👉 "$2}' docs/gen/image-digests.txt -->
<!-- docsub: lines after 1 upto -1 -->
```text
base-2517 👉 sha256:24dcc37b3a4056948f8597f410294285d9fc36f5498ce128f549dae01dde01ab
cpython-2517 👉 sha256:35575dbed8aaba989771ee28948971d52355d586512dd09decceb72b1c180cf7
py27-2517 👉 sha256:fc94ecb658fe22690a26cbabdad01c5b18f8b1a819f1ea8020a318ff8e9bb664
py310-2517 👉 sha256:164286485adb7785e9eb813840aec82eb9d2216b37ac82de069e3794e6888191
py311-2517 👉 sha256:824fcead713fad77d4e7c5e5240ba526c86e83ce6341e7dd6a5f7969b9b23786
py312-2517 👉 sha256:5071b73e4f55af32ca25dcd161ce0dd5be76ec20a85709451a30449e22b87337
py313-2517 👉 sha256:12091f77b5548d42daabe30024a05b3c8ba9121197ac1edc4e94538ac3e27e9f
py313t-2517 👉 sha256:1f1e1f9b0289da360849fa49443f7306cf287ea274f147530765bf22a5f15705
py314-2517 👉 sha256:21b95ff22d207948e908442f41f1169b9bd49bdd6f7004959829fe10d87829eb
py314t-2517 👉 sha256:09c8b4b08cae9c91747c1aa7d958b6c9ffad9c80daad668f555a4c615ececce4
py35-2517 👉 sha256:aaf9506c3a9b6b9fba2606aa586646c3653507ccee5105a8b64bd9b1d92269bb
py36-2517 👉 sha256:b443be7588a65994a61910ee912f442110f68e724069509d38896a37420ba8fb
py37-2517 👉 sha256:a0231c32a7cd2f64f555c9500a9e4ed81a277269cfcda58dc768f8947f93405f
py38-2517 👉 sha256:2793e528d58cdff20cf7199669d153a09591870fb7fd77c12719523c3894ca4c
py39-2517 👉 sha256:d5addd34754f0bda92ffce443b6f1ac8a27491676680c67bd6729470d2e475ca
supported-2517 👉 sha256:a569d378b7c0a23110883bcaf227dd505da037435e24e29db3be338f44e76b3d
unsafe-2517 👉 sha256:8cdd2df01a12bb829a40283aaa6db1860bcd36bf01e4aa87a343f939ccf4d36c
```
<!-- docsub: end -->


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
