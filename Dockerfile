ARG DEBIAN_DIGEST=sha256:b5ace515e78743215a1b101a6f17e59ed74b17132139ca3af3c37e605205e973

# base without helpers

FROM debian@${DEBIAN_DIGEST} AS parent
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
# hadolint ignore=DL3003
RUN <<EOT
    wget -q "https://github.com/pyenv/pyenv/archive/refs/tags/v${PYENV_VERSION}.tar.gz" -O /tmp/pyenv.tar.gz
    echo "${PYENV_SHA256} /tmp/pyenv.tar.gz" | sha256sum --check --strict
    mkdir -p /root/.pyenv
    tar -xzf /tmp/pyenv.tar.gz -C /root/.pyenv --strip-components=1
    cd /root/.pyenv && src/configure && make -C src
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
ENV PATH="/root/.multipython/bin:/root/.multipython/sys/bin:/root/.pyenv/bin:$PATH"
ENTRYPOINT []
CMD ["/bin/bash"]
RUN <<EOT
    mkdir -p /root/.multipython
    echo ${DEBIAN_DIGEST} > /root/.multipython/image
EOT


# base with helpers

FROM parent AS base
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as base
EOT


# single version images

FROM parent AS py27-pyenv
ARG py27
RUN pyenv install ${py27}
FROM py27-pyenv AS py27
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py27
EOT

FROM parent AS py35-pyenv
ARG py35
RUN pyenv install ${py35}
FROM py35-pyenv AS py35
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py35
EOT

FROM parent AS py36-pyenv
ARG py36
RUN pyenv install ${py36}
FROM py36-pyenv AS py36
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py36
EOT

FROM parent AS py37-pyenv
ARG py37
RUN pyenv install ${py37}
FROM py37-pyenv AS py37
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py37
EOT

FROM parent AS py38-pyenv
ARG py38
RUN pyenv install ${py38}
FROM py38-pyenv AS py38
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py38
EOT

FROM parent AS py39-pyenv
ARG py39
RUN pyenv install ${py39}
FROM py39-pyenv AS py39
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py39
EOT

FROM parent AS py310-pyenv
ARG py310
RUN pyenv install ${py310}
FROM py310-pyenv AS py310
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py310
EOT

FROM parent AS py311-pyenv
ARG py311
RUN pyenv install ${py311}
FROM py311-pyenv AS py311
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py311
EOT

FROM parent AS py312-pyenv
ARG py312
RUN pyenv install ${py312}
FROM py312-pyenv AS py312
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py312
EOT

FROM parent AS py313-pyenv
ARG py313
RUN pyenv install ${py313}
FROM py313-pyenv AS py313
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py313
EOT

FROM parent AS py314-pyenv
ARG py314
RUN pyenv install ${py314}
FROM py314-pyenv AS py314
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py314
EOT

FROM parent AS py313t-pyenv
ARG py313t
RUN pyenv install ${py313t}
FROM py313t-pyenv AS py313t
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py313t
EOT

FROM parent AS py314t-pyenv
ARG py314t
RUN pyenv install ${py314t}
FROM py314t-pyenv AS py314t
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as py314t
EOT


# cpython

FROM parent AS cpython
RUN mkdir /root/.pyenv/versions
COPY --from=py313-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as cpython
EOT


# latest

FROM parent AS latest
RUN mkdir /root/.pyenv/versions
COPY --from=py39-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py310-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py311-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py312-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py314-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313t-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py314t-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as latest
EOT


# supported

FROM parent AS supported
RUN mkdir /root/.pyenv/versions
COPY --from=py39-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py310-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py311-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py312-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=py313t-pyenv /root/.pyenv/versions /root/.pyenv/versions/
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as supported
EOT


# unsafe

FROM parent AS unsafe
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
COPY --chmod=755 bin/py.sh /root/.multipython/bin/py
COPY --chmod=755 bin/cmd/* /root/.multipython/bin/cmd/
ARG RELEASE
RUN <<EOT
    echo "${RELEASE}" > /root/.multipython/version
    py install --as unsafe
EOT
