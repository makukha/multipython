variable "IMG" {
  default = "makukha/multipython"
}
variable "RELEASE" {
  default = "2517"
}

variable "BASE_VERSIONS" {
  default = {
    PYENV_VERSION = "2.5.0"
    PYENV_SHA256 = "12c42bdaf3741895ad710a957d44dc2b0c5260f95f857318a6681981fe1b1c0b"
    UV_VERSION = "0.5.15"
    UV_SHA256 = "6c650324daafc07331c00b458872d50f56f160544015c8a499fd2e160b404ebb"
  }
}
variable "PY_VERSIONS" {
  default = {
    py27 = "2.7.18"
    py35 = "3.5.10"
    py36 = "3.6.15"
    py37 = "3.7.17"
    py38 = "3.8.20"
    py39 = "3.9.21"
    py310 = "3.10.16"
    py311 = "3.11.11"
    py312 = "3.12.8"
    py313 = "3.13.1"
    py314 = "3.14.0a3"
    # free threaded
    py313t = "3.13.1t"
    py314t = "3.14.0a3t"
  }
}

# subsets

variable "SUBSET_ARGS" {
  default = {
    latest = {
      SUBSET = "latest"
      RELEASE_TAG = "${RELEASE}"
    }
    cpython = {
      SUBSET = "cpython"
      RELEASE_TAG = "cpython-${RELEASE}"
    }
    supported = {
      SUBSET = "supported"
      RELEASE_TAG = "supported-${RELEASE}"
    }
  }
}


# --- build

group "default" {
  targets = [
    "base",
    "py",
    "latest",
    "cpython",
    "supported",
  ]
}

target "__build__" {
  args = "${merge(BASE_VERSIONS, PY_VERSIONS)}"
  platforms = ["linux/amd64"]
}

target "base" {
  inherits = ["__build__"]
  target = "base"
  tags = [
    "${IMG}:base",
    "${IMG}:base-${RELEASE}",
  ]
}

target "py" {
  inherits = ["__build__"]
  target = PY_TAG
  tags = [
    "${IMG}:${PY_TAG}",
    "${IMG}:${PY_TAG}-${RELEASE}",
  ]
  matrix = {
    PY_TAG = keys(PY_VERSIONS)
  }
  name = PY_TAG
}

target "latest" {
  inherits = ["__build__"]
  target = "latest"
  tags = [
    "${IMG}:latest",
    "${IMG}:${RELEASE}",
  ]
}

target "cpython" {
  inherits = ["__build__"]
  target = "cpython"
  tags = [
    "${IMG}:cpython",
    "${IMG}:cpython-${RELEASE}",
  ]
}

target "supported" {
  inherits = ["__build__"]
  target = "supported"
  tags = [
    "${IMG}:supported",
    "${IMG}:supported-${RELEASE}",
  ]
}


# --- test

group "test" {
  targets = [
    "test_base",
    "test_subsets",
    "test_readme_basic",
    "test_readme_advanced_test",
  ]
}

target "__test__" {
  output = ["type=cacheonly"]
}

target "test_base" {
  inherits = ["__test__"]
  dockerfile-inline = <<EOF
    FROM ${IMG}:base-${RELEASE}
    COPY tests/share /tmp/share
    RUN bash /tmp/share/test_subset.sh base
  EOF
}

target "test_subsets" {
  inherits = ["__test__"]
  dockerfile-inline = <<EOF
    FROM ${IMG}:${SUBSET_ARGS[SUBSET]["RELEASE_TAG"]}
    COPY tests/share /tmp/share
    RUN bash /tmp/share/test_subset.sh "${SUBSET}"
  EOF
  matrix = {
    SUBSET = [
      "latest",
      "cpython",
      "supported",
    ]
  }
  name = "test_subset_${SUBSET}"
}

target "test_readme_basic" {
  inherits = ["__test__"]
  dockerfile-inline = <<EOF
    FROM ${IMG}:${RELEASE}
    COPY tests/test_readme_basic/tox.ini ./
    RUN tox run
  EOF
}

target "test_readme_advanced_setup" {
  dockerfile = "tests/test_readme_advanced/Dockerfile"
}

target "test_readme_advanced_test" {
  inherits = ["__test__"]
  contexts = {
    setup = "target:test_readme_advanced_setup"
  }
  dockerfile-inline = <<EOF
    FROM setup
    COPY tests/share /tmp/share
    COPY tests/test_readme_advanced/info.json /tmp/share/info/test_readme_advanced.json
    RUN bash /tmp/share/test_subset.sh test_readme_advanced
  EOF
}
