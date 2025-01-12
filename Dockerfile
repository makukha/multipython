ARG DEBIAN_DIGEST=sha256:5f21ebd358442f40099c997a3f4db906a7b1bd872249e67559f55de654b55d3b
ARG PYENV_ROOT=/root/.pyenv
ARG MULTIPYTHON_ROOT=/root/.multipython

# base

FROM debian@${DEBIAN_DIGEST} AS base
SHELL ["/bin/bash", "-o", "errexit", "-o", "errtrace", "-o", "nounset", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN <<EOT
    apt-get update
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        jq \
        lcov \
        libbz2-dev \
        libffi-dev \
        libgdbm-compat-dev \
        libgdbm-dev \
        liblzma-dev \
        libncursesw5-dev \
        libreadline6-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        libxmlsec1-dev \
        llvm \
        lzma \
        lzma-dev \
        pkg-config \
        tk-dev \
        uuid-dev \
        wget \
        xz-utils \
        zlib1g-dev
    rm -rf /var/lib/apt/lists/*
EOT

ARG PYENV_VERSION
ARG PYENV_SHA256
ARG PYENV_ROOT
# hadolint ignore=DL3003
RUN <<EOT
    wget -q "https://github.com/pyenv/pyenv/archive/refs/tags/v${PYENV_VERSION}.tar.gz" -O /tmp/pyenv.tar.gz
    echo "${PYENV_SHA256} /tmp/pyenv.tar.gz" | sha256sum --check --strict
    mkdir -p ${PYENV_ROOT}
    tar -xzf /tmp/pyenv.tar.gz -C ${PYENV_ROOT} --strip-components=1
    cd ${PYENV_ROOT} && src/configure && make -C src
    rm -rf /tmp/* /var/tmp/*
EOT

ARG UV_VERSION
ARG UV_SHA256
RUN <<EOT
    wget -q "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz" -O /tmp/uv.tar.gz
    echo "${UV_SHA256} /tmp/uv.tar.gz" | sha256sum --check --strict
    tar -xzf /tmp/uv.tar.gz -C /usr/local/bin --strip-components=1
    rm -rf /tmp/* /var/tmp/*
EOT

ARG DEBIAN_DIGEST
ARG MULTIPYTHON_ROOT
ENV PATH="$MULTIPYTHON_ROOT/sys:$PYENV_ROOT/bin:$PATH"
COPY --chmod=755 bin/py.sh /usr/local/bin/py
COPY --chmod=755 bin/checkupd.sh $MULTIPYTHON_ROOT/
RUN <<EOT
echo "${DEBIAN_DIGEST}" > "${MULTIPYTHON_ROOT}/base_image_digest"
echo "base" > "${MULTIPYTHON_ROOT}/subset"
py info | tee "${MULTIPYTHON_ROOT}/info.json" | jq
EOT

ENV VIRTUALENV_DISCOVERY=multipython
ENTRYPOINT []
CMD ["/bin/bash"]


# single version images

FROM base AS py27-pyenv
ARG py27
RUN pyenv install ${py27}
FROM py27-pyenv AS py27
RUN py install

FROM base AS py35-pyenv
ARG py35
RUN pyenv install ${py35}
FROM py35-pyenv AS py35
RUN py install

FROM base AS py36-pyenv
ARG py36
RUN pyenv install ${py36}
FROM py36-pyenv AS py36
RUN py install

FROM base AS py37-pyenv
ARG py37
RUN pyenv install ${py37}
FROM py37-pyenv AS py37
RUN py install

FROM base AS py38-pyenv
ARG py38
RUN pyenv install ${py38}
FROM py38-pyenv AS py38
RUN py install

FROM base AS py39-pyenv
ARG py39
RUN pyenv install ${py39}
FROM py39-pyenv AS py39
RUN py install

FROM base AS py310-pyenv
ARG py310
RUN pyenv install ${py310}
FROM py310-pyenv AS py310
RUN py install

FROM base AS py311-pyenv
ARG py311
RUN pyenv install ${py311}
FROM py311-pyenv AS py311
RUN py install

FROM base AS py312-pyenv
ARG py312
RUN pyenv install ${py312}
FROM py312-pyenv AS py312
RUN py install

FROM base AS py313-pyenv
ARG py313
RUN pyenv install ${py313}
FROM py313-pyenv AS py313
RUN py install

FROM base AS py314-pyenv
ARG py314
RUN pyenv install ${py314}
FROM py314-pyenv AS py314
RUN py install

FROM base AS py313t-pyenv
ARG py313t
RUN pyenv install ${py313t}
FROM py313t-pyenv AS py313t
RUN py install

FROM base AS py314t-pyenv
ARG py314t
RUN pyenv install ${py314t}
FROM py314t-pyenv AS py314t
RUN py install


# cpython

FROM base AS cpython
RUN mkdir /root/.pyenv/versions
COPY --from=py313-pyenv /root/.pyenv/versions /root/.pyenv/versions/
RUN py install --as cpython


# latest

FROM base AS latest
RUN mkdir /root/.pyenv/versions
COPY --from=py39-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py310-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py311-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py312-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py314-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313t-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py314t-pyenv /root/.pyenv/versions /root/.pyenv/versions/
RUN py install --as latest


# supported

FROM base AS supported
RUN mkdir /root/.pyenv/versions
COPY --from=py39-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py310-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py311-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py312-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313t-pyenv /root/.pyenv/versions /root/.pyenv/versions/
RUN py install --as supported


# unsafe

FROM base AS unsafe
RUN mkdir /root/.pyenv/versions
COPY --from=py27-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py35-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py36-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py37-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py38-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py39-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py310-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py311-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py312-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py314-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313t-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py314t-pyenv /root/.pyenv/versions /root/.pyenv/versions/
RUN py install --as unsafe
