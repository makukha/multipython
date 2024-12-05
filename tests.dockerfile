# hadolint global ignore=DL3013,DL4006
# DL3042 => pip install without version is fine for README docs
# DL4006 => -o pipefail is already set globally

FROM scratch AS toxfile

ARG py27 py35 py36 py37 py38 py39 py310 py311 py312 py313 py314 py313t py314t

COPY <<EOT /tox.ini
[tox]
env_list = py{27,35,36,37,38,39,310,311,312,313,314,313t,314t}
skip_missing_interpreters = false
[testenv]
allowlist_externals = bash
base_python =
  py313t: python3.13t
  py314t: python3.14t
set_env =
  py27: V=${py27}
  py27: P=${py27} (
  py35: V=${py35}
  py35: P=${py35} (
  py36: V=${py36}
  py36: P=${py36} (
  py37: V=${py37}
  py37: P=${py37} (
  py38: v=${py38}
  py38: P=${py38} (
  py39: V=${py39}
  py39: P=${py39} (
  py310: V=${py310}
  py310: P=${py310} (
  py311: V=${py311}
  py311: P=${py311} (
  py312: V=${py312}
  py312: P=${py312} (
  py313: V=${py313}
  py313: P=${py313} (
  py314: V=${py314}
  py314: P=${py314} (
  py313t: V=${py313t}
  py313t: P=${py313t%t} experimental free-threading build (
  py314t: V=${py314t}
  py314t: P=${py314t%t} experimental free-threading build (
commands =
  bash -c '[[ "\$(python\$(py --to-minor "{env:V}") -c "import sys; print(sys.version)")" == "{env:P}"* ]] || exit 1'
EOT


# --- final

# test

FROM makukha/multipython:2024.12.1 AS test_final

ARG py27 py35 py36 py37 py38 py39 py310 py311 py312 py313 py314 py313t py314t
COPY --from=toxfile /tox.ini /tmp/

COPY <<EOT /tmp/usage.txt
Usage: py <option>

  Multipython helper utility.

Options:
  --list   Show all versions installed
  --minor  Show minor versions installed
  --tags   Show tags of versions installed
  --sys    Show version of system python
  --help   Show this help and exit

Advanced options:
  --link-pyenv      Symlink all python versions (use in Dockerfile only)
  --link-sys VER    Symlink system python (use in Dockerfile only)
  --root            Show path to multipython root directory
  --to-minor -|VER  Convert full version from stdin or value to minor format
  --to-tag -|VER    Convert full version from stdin or value to tag format
EOT

COPY <<EOT /tmp/versions.txt
${py27}
${py35}
${py36}
${py37}
${py38}
${py39}
${py310}
${py311}
${py312}
${py313}
${py313t}
${py314}
${py314t}
EOT

COPY <<EOT /tmp/minor.txt
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
EOT

COPY <<EOT /tmp/tags.txt
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
EOT

WORKDIR /tmp
RUN <<-EOT
  py --help | diff usage.txt -
  py --list | diff versions.txt -
  py --minor | diff minor.txt -
  py --tags | diff tags.txt -
  tox run -e py27 -e py35 -e py36 -e py37 -e py38 -e py39 -e py310 -e py311 -e py312 -e py313 -e py314 -e py313t -e py314t
EOT


# --- readme example 1

# setup

FROM makukha/multipython:pyenv AS readme_example_1
RUN mkdir /root/.pyenv/versions
COPY --from=makukha/multipython:py27 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py35 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py36 /root/.pyenv/versions /root/.pyenv/versions/
RUN py --link-pyenv; py --link-sys py36

# test

FROM readme_example_1 AS test_readme_example_1

ARG py27 py35 py36 py313
COPY --from=toxfile /tox.ini /tmp/

COPY <<EOT /tmp/versions.txt
${py27}
${py35}
${py36}
EOT

WORKDIR /tmp
RUN <<-EOT
  py --list | diff versions.txt -
  tox run -e py27 -e py35 -e py36
EOT


# --- readme example 2

# setup

FROM makukha/multipython:pyenv AS readme_example_2
RUN mkdir /root/.pyenv/versions
COPY --from=makukha/multipython:py37 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py314 /root/.pyenv/versions /root/.pyenv/versions/
# set global pyenv versions and create symlinks
# pin virtualenv to support Python 3.7
RUN py --link-pyenv; \
    py --link-sys py314; \
    pip install --no-cache-dir "virtualenv<20.27" tox

# test

FROM readme_example_2 AS test_readme_example_2

ARG py37 py313 py314
COPY --from=toxfile /tox.ini /tmp/

COPY <<EOT /tmp/versions.txt
${py37}
${py314}
EOT

WORKDIR /tmp
RUN <<-EOT
  py --list | diff versions.txt -
  tox run -e py37 -e py314
EOT


# --- readme example 3

# setup

FROM makukha/multipython:pyenv AS readme_example_3
RUN mkdir /root/.pyenv/versions
COPY --from=makukha/multipython:py312 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py313 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py314 /root/.pyenv/versions /root/.pyenv/versions/
# set global pyenv versions and create symlinks
# use latest tox and virtualenv
RUN py --link-pyenv; \
    py --link-sys py314; \
    pip install --no-cache-dir tox

# test

FROM readme_example_3 AS test_readme_example_3

ARG py312 py313 py314
COPY --from=toxfile /tox.ini /tmp/

COPY <<EOT /tmp/versions.txt
${py312}
${py313}
${py314}
EOT

WORKDIR /tmp
RUN <<-EOT
  py --list | diff versions.txt -
  tox run -e py312 -e py313 -e py314
EOT
