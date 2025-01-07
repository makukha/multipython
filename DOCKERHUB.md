[![GitHub Release](https://img.shields.io/github/v/tag/makukha/multipython?label=release)](https://github.com/makukha/multipython)°[![GitHub Release Date](https://img.shields.io/github/release-date/makukha/multipython?label=release%20date)](https://github.com/makukha/multipython)°[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9755/badge)](https://www.bestpractices.dev/projects/9755)

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

# Quick reference

* **Supported architectures**: `amd64`
* **Maintained by**: [Michael Makukha](https://github.com/makukha)
* **Where to get help**: [GitHub repository](https://github.com/makukha/multipython)
* **Where to file issues**: [GitHub issues](https://github.com/makukha/multipython/issues)
* **Documentation**: [github.com/makukha/multipython](https://github.com/makukha/multipython)

# Supported tags and respective `Dockerfile` links

<!-- docsub: begin -->
<!-- docsub: include docs/part/image-tags.md -->
* [`latest, 2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *all supported and prerelease CPython versions*
* [`cpython, cpython-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.13.1 — latest version*
* [`supported, supported-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *all supported CPython versions*
* [`unsafe, unsafe-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *all CPython versions, including EOL*
* [`base, base-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *pyenv, uv*
* [`py314t, py314t-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.14.0a3 free-threaded*
* [`py313t, py313t-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.13.1 free-threaded*
* [`py314, py314-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.14.0a3*
* [`py313, py313-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.13.1*
* [`py312, py312-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.12.8*
* [`py311, py311-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.11.11*
* [`py310, py310-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.10.16*
* [`py39, py39-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.9.21*
* [`py38, py38-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.8.20*
* [`py37, py37-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.7.17*
* [`py36, py36-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.6.15*
* [`py35, py35-2517`](https://github.com/makukha/multipython/blob/v2517/Dockerfile) — *CPython 3.5.10*
* [`py27, py27-2517`](https://github.co-m/makukha/multipython/blob/v2517/Dockerfile) — *CPython 2.7.18*

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


# Documentation

* [Building your own](https://github.com/makukha/multipython?tab=readme-ov-file#build-your-own-environment) environment
* [Helper utility](https://github.com/makukha/multipython?tab=readme-ov-file#cli-helper-utility-py) usage
* [JSON metadata](https://github.com/makukha/multipython?tab=readme-ov-file#json-metadata) sources
* [Package versions](https://github.com/makukha/multipython?tab=readme-ov-file#python-packages) installed
* [Security](https://github.com/makukha/multipython?tab=readme-ov-file#security) measures

# Image digests

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

# Feedback and contributing

<!-- docsub: begin -->
<!-- docsub: include docs/part/feedback.md -->
* To file bug report or feature request, please [create an issue](https://github.com/makukha/multipython/issues).
* To report security vulnerability, please use [GitHub Security Advisories](https://github.com/makukha/multipython/security/advisories).
* Want to contribute? Check [Contribution Guidelines](https://github.com/makukha/multipython/blob/main/.github/CONTRIBUTING.md).
<!-- docsub: end -->
