ARG PYENV_INSTALLER_BRANCH=86a08ac
ARG PYENV_INSTALLER_SHA256=a1ad63c22842dce498b441551e2f83ede3e3b6ebb33f62013607bba424683191
ARG TOX_VERSION=4.5.1.1
ARG VIRTUALENV_VERSION=20.21.1

ARG PY27=2.7.18
ARG PY35=3.5.10
ARG PY36=3.6.15
ARG PY37=3.7.17
ARG PY38=3.8.20
ARG PY39=3.9.20
ARG PY310=3.10.15
ARG PY311=3.11.10
ARG PY312=3.12.7
ARG PY313=3.13.0
ARG PY314=3.14.0a2

# base image

FROM python:${PY313}-slim-bookworm AS base
SHELL ["/bin/sh", "-eux", "-c"]

ARG PYENV_INSTALLER_BRANCH
ARG PYENV_INSTALLER_SHA256

ENV PYENV_ROOT=/root/.pyenv

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
<<EOT
apt-get update
apt-get install -y --no-install-recommends \
    build-essential gdb git lcov pkg-config wget \
    libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
    lzma lzma-dev tk-dev uuid-dev zlib1g-dev
wget -qO- https://github.com/pyenv/pyenv-installer/raw/${PYENV_INSTALLER_BRANCH}/bin/pyenv-installer \
    > /tmp/pyenv-installer
echo "${PYENV_INSTALLER_SHA256} /tmp/pyenv-installer" | sha256sum --check --strict
bash /tmp/pyenv-installer
ln -s ${PYENV_ROOT}/bin/pyenv /usr/local/bin/pyenv
pyenv update
rm -rf /tmp/* /var/tmp/*
EOT

ENTRYPOINT []
CMD /bin/bash

# build versions

FROM base AS py27
ARG PY27
RUN pyenv install ${PY27}

FROM base AS py35
ARG PY35
RUN pyenv install ${PY35}

FROM base AS py36
ARG PY36
RUN pyenv install ${PY36}

FROM base AS py37
ARG PY37
RUN pyenv install ${PY37}

FROM base AS py38
ARG PY38
RUN pyenv install ${PY38}

FROM base AS py39
ARG PY39
RUN pyenv install ${PY39}

FROM base AS py310
ARG PY310
RUN pyenv install ${PY310}

FROM base AS py311
ARG PY311
RUN pyenv install ${PY311}

FROM base AS py312
ARG PY312
RUN pyenv install ${PY312}

FROM base AS py314
ARG PY314
RUN pyenv install ${PY314}

# final image

FROM base AS default

ARG TOX_VERSION
ARG VIRTUALENV_VERSION
ARG PY27 PY35 PY36 PY37 PY38 PY39 PY310 PY311 PY312 PY313 PY314

RUN --mount=type=cache,dst=/root/.cache/pip \
    --mount=type=bind,from=py27,src=/root/.pyenv,dst=/tmp/py27 \
    --mount=type=bind,from=py35,src=/root/.pyenv,dst=/tmp/py35 \
    --mount=type=bind,from=py36,src=/root/.pyenv,dst=/tmp/py36 \
    --mount=type=bind,from=py37,src=/root/.pyenv,dst=/tmp/py37 \
    --mount=type=bind,from=py38,src=/root/.pyenv,dst=/tmp/py38 \
    --mount=type=bind,from=py39,src=/root/.pyenv,dst=/tmp/py39 \
    --mount=type=bind,from=py310,src=/root/.pyenv,dst=/tmp/py310 \
    --mount=type=bind,from=py311,src=/root/.pyenv,dst=/tmp/py311 \
    --mount=type=bind,from=py312,src=/root/.pyenv,dst=/tmp/py312 \
    --mount=type=bind,from=py314,src=/root/.pyenv,dst=/tmp/py314 \
<<EOT

mkdir -p /root/.pyenv/versions
cp -a /tmp/py*/versions/* /root/.pyenv/versions
pyenv install --skip-existing $PY27 $PY35 $PY36 $PY37 $PY38 $PY39 $PY310 $PY311 $PY312 $PY314

ln -s ${PYENV_ROOT}/versions/$PY27/bin/python /usr/local/bin/python2.7
ln -s ${PYENV_ROOT}/versions/$PY35/bin/python /usr/local/bin/python3.5
ln -s ${PYENV_ROOT}/versions/$PY36/bin/python /usr/local/bin/python3.6
ln -s ${PYENV_ROOT}/versions/$PY37/bin/python /usr/local/bin/python3.7
ln -s ${PYENV_ROOT}/versions/$PY38/bin/python /usr/local/bin/python3.8
ln -s ${PYENV_ROOT}/versions/$PY39/bin/python /usr/local/bin/python3.9
ln -s ${PYENV_ROOT}/versions/$PY310/bin/python /usr/local/bin/python3.10
ln -s ${PYENV_ROOT}/versions/$PY311/bin/python /usr/local/bin/python3.11
ln -s ${PYENV_ROOT}/versions/$PY312/bin/python /usr/local/bin/python3.12
# python3.13 comes from base image
ln -s ${PYENV_ROOT}/versions/$PY314/bin/python /usr/local/bin/python3.14

pip install --disable-pip-version-check --root-user-action=ignore \
    virtualenv==${VIRTUALENV_VERSION} \
    tox==${TOX_VERSION}
EOT

# test

FROM default AS test

RUN <<EOT
mkdir /tmp/test
cat <<EOF > /tmp/test/tox.ini
[tox]
env_list = py{27,35,36,37,38,39,310,311,312,313,314}
skip_missing_interpreters = false
[testenv]
allowlist_externals = bash
[testenv:py27]
commands = bash -c 'test "\$({envpython} --version 2>&1)" == "Python ${PY27}"'
[testenv:py35]
commands = bash -c 'test "\$({envpython} --version)" == "Python ${PY35}"'
[testenv:py36]
commands = bash -c 'test "\$({envpython} --version)" == "Python ${PY36}"'
[testenv:py37]
commands = bash -c 'test "\$({envpython} --version)" == "Python ${PY37}"'
[testenv:py38]
commands = bash -c 'test "\$({envpython} --version)" == "Python ${PY38}"'
[testenv:py39]
commands = bash -c 'test "\$({envpython} --version)" == "Python ${PY39}"'
[testenv:py310]
commands = bash -c 'test "\$({envpython} --version)" == "Python ${PY310}"'
[testenv:py311]
commands = bash -c 'test "\$({envpython} --version)" == "Python ${PY311}"'
[testenv:py312]
commands = bash -c 'test "\$({envpython} --version)" == "Python ${PY312}"'
[testenv:py313]
commands = bash -c 'test "\$({envpython} --version)" == "Python ${PY313}"'
[testenv:py314]
commands = bash -c 'test "\$({envpython} --version)" == "Python ${PY314}"'
EOF
cd /tmp/test
tox run
cd /
rm -rf /tmp/test
EOT
