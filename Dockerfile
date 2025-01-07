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
COPY tests/share/data/verbose.txt $MULTIPYTHON_ROOT/
RUN <<EOT
echo "${DEBIAN_DIGEST}" > "${MULTIPYTHON_ROOT}/base_image_digest"
echo "base" > "${MULTIPYTHON_ROOT}/subset"
py info | tee "${MULTIPYTHON_ROOT}/info.json" | jq
EOT

ENV VIRTUALENV_DISCOVERY=multipython
ENTRYPOINT []
CMD ["/bin/bash"]


# single version images

FROM base AS py27
ARG py27
RUN pyenv install ${py27}; py install

FROM base AS py35
ARG py35
RUN pyenv install ${py35}; py install

FROM base AS py36
ARG py36
RUN pyenv install ${py36}; py install

FROM base AS py37
ARG py37
RUN pyenv install ${py37}; py install

FROM base AS py38
ARG py38
RUN pyenv install ${py38}; py install

FROM base AS py39
ARG py39
RUN pyenv install ${py39}; py install

FROM base AS py310
ARG py310
RUN pyenv install ${py310}; py install

FROM base AS py311
ARG py311
RUN pyenv install ${py311}; py install

FROM base AS py312
ARG py312
RUN pyenv install ${py312}; py install

FROM base AS py313
ARG py313
RUN pyenv install ${py313}; py install

FROM base AS py314
ARG py314
RUN pyenv install ${py314}; py install

FROM base AS py313t
ARG py313t
RUN pyenv install ${py313t}; py install

FROM base AS py314t
ARG py314t
RUN pyenv install ${py314t}; py install


# cpython

FROM base AS cpython
RUN mkdir /root/.pyenv/versions
COPY --from=py313 /root/.pyenv/versions /root/.pyenv/versions/
RUN py install --as cpython


# latest

FROM base AS latest
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
COPY --from=py313 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py314 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313t /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py314t /root/.pyenv/versions /root/.pyenv/versions/
RUN py install --as latest


# supported

FROM base AS supported
RUN mkdir /root/.pyenv/versions
COPY --from=py39 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py310 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py311 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py312 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313t /root/.pyenv/versions /root/.pyenv/versions/
RUN py install --as supported
