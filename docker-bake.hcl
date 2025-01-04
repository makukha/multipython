variable "IMG" {
  default = "makukha/multipython"
}
variable "RELEASE" {
  default = "2025.1.3"
}

variable "BASE_VERSIONS" {
  default = {
    PYENV_VERSION = "2.5.0"
    PYENV_SHA256 = "12c42bdaf3741895ad710a957d44dc2b0c5260f95f857318a6681981fe1b1c0b"
    UV_VERSION = "0.5.14"
    UV_SHA256 = "22034760075b92487b326da5aa1a2a3e1917e2e766c12c0fd466fccda77013c7"
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
    stable = {
      SUBSET = "stable"
      RELEASE_TAG = "stable-${RELEASE}"
    }
  }
}


# --- build

group "default" {
  targets = [
    "base",
    "py",
    "latest",
    "stable",
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

target "stable" {
  inherits = ["__build__"]
  target = "stable"
  tags = [
    "${IMG}:stable",
    "${IMG}:stable-${RELEASE}",
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
    COPY tests/shared /tmp/shared
    RUN bash /tmp/shared/test_subset.sh base
  EOF
}

target "test_subsets" {
  inherits = ["__test__"]
  dockerfile-inline = <<EOF
    FROM ${IMG}:${SUBSET_ARGS[SUBSET]["RELEASE_TAG"]}
    COPY tests/shared /tmp/shared
    RUN bash /tmp/shared/test_subset.sh "${SUBSET}"
  EOF
  matrix = {
    SUBSET = [
      "latest",
      "stable",
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
  tags = ["${IMG}:test_readme_advanced_setup"]
}

target "test_readme_advanced_test" {
  inherits = ["__test__"]
  contexts = {
    setup = "target:test_readme_advanced_setup"
  }
  dockerfile-inline = <<EOF
    FROM setup
    COPY tests/shared /tmp/shared
    COPY tests/test_readme_advanced/info.json /tmp/shared/test_readme_advanced/info.json
    RUN bash /tmp/shared/test_subset.sh test_readme_advanced
  EOF
}
