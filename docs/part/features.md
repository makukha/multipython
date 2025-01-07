* `makukha/multipython` — prerelease and [supported](https://devguide.python.org/versions) Python distributions
* `makukha/multipython:cpython` — latest bugfix CPython image
* `makukha/multipython:supported` — [supported](https://devguide.python.org/versions) versions, not including prerelease
* `makukha/multipython:unsafe` — all versions, including EOL
* `makukha/multipython:{py314...}` — single version images
* All images include [pip](https://pip.pypa.io), [pyenv](https://github.com/pyenv/pyenv), [tox](https://tox.wiki), [uv](https://docs.astral.sh/uv)
* Tox env names match tag names, even non-standard `py313t`
* [Build your own environment](https://github.com/makukha/multipython#build-your-own-environment) from single version images
* Based on `debian:stable-slim`
* Single platform `linux/amd64`
