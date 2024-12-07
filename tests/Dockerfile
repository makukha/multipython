# hadolint global ignore=DL4006
# DL4006 => -o pipefail is already set globally

ARG RELEASE=__REQUIRED__
ARG PYMIN_LONG=2.7.18
ARG PYSYS_LONG=3.13.1
ARG PYSYS_TAG=py313
ARG PYMAX_LONG=3.14.0a2


# --- base

FROM makukha/multipython:pyenv-${RELEASE} AS test-base
ARG PYMIN_LONG
ARG PYSYS_LONG
ARG PYSYS_TAG
ARG PYMAX_LONG
COPY --from=makukha/multipython:py313 /root/.pyenv/versions /root/.pyenv/versions/
COPY files/ /tmp/files
COPY test_py.sh /tmp/
WORKDIR /tmp
# hadolint ignore=SC2016
RUN <<EOT
    BASE="$(pyenv root)/versions"
    for v in $(tac /tmp/files/dist-long.txt | sed '/^${PYSYS_LONG}$/d'); do
      mkdir -p "$BASE/$v/bin"
      touch "$BASE/$v/bin/python"
      chmod a+x "$BASE/$v/bin/python"
    done
    py install --sys ${PYSYS_TAG} --tox
    bash test_py.sh "${PYMIN_LONG}" "${PYSYS_LONG}" "${PYMAX_LONG}"
EOT


# --- final

FROM makukha/multipython:${RELEASE} AS test-final
ARG PYMIN_LONG
ARG PYSYS_LONG
ARG PYMAX_LONG
COPY files/ /tmp/files
COPY test_py.sh /tmp/
WORKDIR /tmp
RUN bash test_py.sh "${PYMIN_LONG}" "${PYSYS_LONG}" "${PYMAX_LONG}"


# --- readme basic

FROM makukha/multipython:${RELEASE} AS test-readme-basic
RUN <<EOT
cat <<EOF > tox.ini
[tox]
env_list = py{27,35,36,37,38,39,310,311,312,313,314,313t,314t}
[testenv]
command = python --version
[testenv:py313t]
base_python = python3.13t
[testenv:py314t]
base_python = python3.14t
EOF
tox run
EOT


# --- readme advanced

FROM makukha/multipython:pyenv-${RELEASE} AS test-readme-advanced
RUN mkdir /root/.pyenv/versions
COPY --from=makukha/multipython:py27 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py35 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py312 /root/.pyenv/versions /root/.pyenv/versions/
RUN py install --sys py312 --tox
# test
COPY files/ /tmp/files
RUN <<EOT
    test "$(py ls --tag | xargs)" = "py27 py35 py312"
    test "$(py version --sys --nodot)" = "312"
EOT


# --- tox

FROM scratch AS util
COPY <<EOF /checkver.py
import sys
from packaging.specifiers import SpecifierSet
from packaging.version import Version
match = Version(sys.argv[1]) in SpecifierSet(sys.argv[2])
sys.exit(int(not match))
EOF

FROM makukha/multipython:pyenv-${RELEASE} AS test-tox-36
RUN mkdir /root/.pyenv/versions
COPY --from=makukha/multipython:py36 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py313 /root/.pyenv/versions /root/.pyenv/versions/
RUN py install --sys py313 --tox
# test
COPY --from=util /checkver.py /tmp/
RUN <<EOT
    python /tmp/checkver.py "$(python -m virtualenv --version | cut -d' ' -f2)" "<20.22"
    python /tmp/checkver.py "$(tox -q --version | cut -d' ' -f1)" "<4.6"
EOT

FROM makukha/multipython:pyenv-${RELEASE} AS test-tox-37
RUN mkdir /root/.pyenv/versions
COPY --from=makukha/multipython:py37 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py313 /root/.pyenv/versions /root/.pyenv/versions/
RUN py install --sys py313 --tox
# test
COPY --from=util /checkver.py /tmp/
RUN <<EOT
    python /tmp/checkver.py "$(python -m virtualenv --version | cut -d' ' -f2)" ">20.26,<20.27"
    python /tmp/checkver.py "$(tox -q --version | cut -d' ' -f1)" ">4.6"
EOT

FROM makukha/multipython:pyenv-${RELEASE} AS test-tox-38
RUN mkdir /root/.pyenv/versions
COPY --from=makukha/multipython:py38 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py313 /root/.pyenv/versions /root/.pyenv/versions/
RUN py install --sys py313 --tox
# test
COPY --from=util /checkver.py /tmp/
RUN <<EOT
    python /tmp/checkver.py "$(python -m virtualenv --version | cut -d' ' -f2)" ">20.27"
    python /tmp/checkver.py "$(tox -q --version | cut -d' ' -f1)" ">4.6"
EOT
