# hadolint global ignore=DL3008,DL4006
# DL3008 => apt pakage versions are not locked in this project
# DL4006 => -o pipefail is already set globally

ARG PYENV_VERSION=__REQUIRED__

# pyenv

FROM python:3.13.0-slim-bookworm AS pyenv
SHELL ["/bin/bash", "-eux", "-o", "pipefail", "-c"]

ARG PYENV_VERSION
ARG PYENV_SHA256
ARG TOX_VERSION
ARG VIRTUALENV_VERSION

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
<<-EOT
    apt-get update
    apt-get install -y --no-install-recommends \
        build-essential ca-certificates curl git lcov llvm pkg-config wget \
        lzma lzma-dev tk-dev uuid-dev xz-utils zlib1g-dev \
        libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
        libncursesw5-dev libreadline6-dev libsqlite3-dev libssl-dev libxml2-dev libxmlsec1-dev
    rm -rf /tmp/* /var/tmp/*
EOT

RUN pip install --disable-pip-version-check --root-user-action=ignore --no-cache-dir \
        virtualenv==${VIRTUALENV_VERSION} \
        tox==${TOX_VERSION}

ENV PYENV_ROOT=/root/.pyenv
ENV PATH="$PYENV_ROOT/bin:$PATH"

# hadolint ignore=DL3003
RUN <<-EOT
    wget -q https://github.com/pyenv/pyenv/archive/refs/tags/v${PYENV_VERSION}.tar.gz -O /tmp/pyenv.tar.gz
    echo "${PYENV_SHA256} /tmp/pyenv.tar.gz" | sha256sum --check --strict
    mkdir -p ${PYENV_ROOT}
    tar -xzf /tmp/pyenv.tar.gz -C ${PYENV_ROOT} --strip-components=1
    cd ${PYENV_ROOT} && src/configure && make -C src
    rm -rf /tmp/* /var/tmp/*
EOT

COPY --chmod=755 py.sh /usr/local/bin/py

ENTRYPOINT []
CMD ["/bin/bash"]

# single versions

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py27
ARG py27
RUN --mount=type=cache,dst=/root/.pyenv/cache pyenv install ${py27}; py --install

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py35
ARG py35
RUN --mount=type=cache,dst=/root/.pyenv/cache pyenv install ${py35}; py --install

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py36
ARG py36
RUN --mount=type=cache,dst=/root/.pyenv/cache pyenv install ${py36}; py --install

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py37
ARG py37
RUN --mount=type=cache,dst=/root/.pyenv/cache pyenv install ${py37}; py --install

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py38
ARG py38
RUN --mount=type=cache,dst=/root/.pyenv/cache pyenv install ${py38}; py --install

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py39
ARG py39
RUN --mount=type=cache,dst=/root/.pyenv/cache pyenv install ${py39}; py --install

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py310
ARG py310
RUN --mount=type=cache,dst=/root/.pyenv/cache pyenv install ${py310}; py --install

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py311
ARG py311
RUN --mount=type=cache,dst=/root/.pyenv/cache pyenv install ${py311}; py --install

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py312
ARG py312
RUN --mount=type=cache,dst=/root/.pyenv/cache pyenv install ${py312}; py --install

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py313
ARG py313
RUN --mount=type=cache,dst=/root/.pyenv/cache \
    test "$(py --sys)" = "${py313}"; \
    mkdir -p /root/.pyenv/versions

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py314
ARG py314
RUN --mount=type=cache,dst=/root/.pyenv/cache pyenv install ${py314}; py --install

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py313t
ARG py313t
RUN --mount=type=cache,dst=/root/.pyenv/cache pyenv install ${py313t}; py --install

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS py314t
ARG py314t
RUN --mount=type=cache,dst=/root/.pyenv/cache pyenv install ${py314t}; py --install

# final

FROM makukha/multipython:pyenv-${PYENV_VERSION} AS multipython
RUN mkdir /root/.pyenv/versions
COPY --from=py27 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py35 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py36 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py37 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py38 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py39 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py310 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py311 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py312 /root/.pyenv/versions /root/.pyenv/versions/
# NOTE: py313 comes from the base image
COPY --from=py314 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313t /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py314t /root/.pyenv/versions /root/.pyenv/versions/
RUN py --install
