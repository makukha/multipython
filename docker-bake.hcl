variable "IMG" {
  default = "makukha/multipython"
}
variable "RELEASE" {
  default = "252D"
}

variable "BASE_VERSIONS" {
  default = {
    RELEASE = "${RELEASE}"
    PYENV_VERSION = "2.5.3"
    PYENV_SHA256 = "2068872d4f3174d697bcfd602ada3dc2b7764e84f73be7850c0de86fbf00f69e"
    UV_VERSION = "0.5.31"
    UV_SHA256 = "017ce7ed02c967f1b0489f09162e19ee3df4586a44e681211d16206e007fce62"
  }
}

variable "SINGLE_VERSIONS" {
  default = {
    # cpython
    py27 = "2.7.18"
    py35 = "3.5.10"
    py36 = "3.6.15"
    py37 = "3.7.17"
    py38 = "3.8.20"
    py39 = "3.9.21"
    py310 = "3.10.16"
    py311 = "3.11.11"
    py312 = "3.12.9"
    py313 = "3.13.2"
    py314 = "3.14.0a5"
    # cpython, free threaded
    py313t = "3.13.2t"
    py314t = "3.14.0a5t"
  }
}

variable "DERIVED" {
  default = [
    # NOTE: the order is important, lower tags will appear higher on Docker Hub
    # latest implementations
    "cpython",
    # more general
    "base",
    "unsafe",
    "latest",
    "supported",
  ]
}

function "release_tag" {
  params = [subset, release]
  result = replace("${subset}-${release}", "latest-", "")
}


# --- build

target "default" {
  args = merge(BASE_VERSIONS, SINGLE_VERSIONS)
  platforms = ["linux/amd64"]
  target = SUBSET
  matrix = {
    SUBSET = concat(keys(SINGLE_VERSIONS), DERIVED)
  }
  name = SUBSET
  tags = [
    "${IMG}:${SUBSET}",
    "${IMG}:${release_tag(SUBSET, RELEASE)}",
  ]
}


# --- test

group "test" {
  targets = [
    "checkupd",
    "test_subsets",
    "test_readme_basic",
    "test_readme_advanced_test",
  ]
}

target "__test__" {
  output = ["type=cacheonly"]
}

target "checkupd" {
  inherits = ["__test__"]
  dockerfile-inline = <<EOF
    FROM ${IMG}:base-${RELEASE}
    RUN py checkupd
  EOF
}

target "test_subsets" {
  inherits = ["__test__"]
  args = {
    MULTIPYTHON_DEBUG = "false"
  }
  dockerfile-inline = <<EOF
    FROM ${IMG}:${release_tag(SUBSET, RELEASE)}
    COPY tests/share /tmp/share
    ARG MULTIPYTHON_DEBUG
    ENV MULTIPYTHON_DEBUG="$${MULTIPYTHON_DEBUG}"
    RUN bash /tmp/share/test_subset.sh "${SUBSET}"
  EOF
  matrix = {
    SUBSET = concat(keys(SINGLE_VERSIONS), DERIVED)
  }
  name = "test_subset_${SUBSET}"
}

target "test_readme_basic" {
  inherits = ["__test__"]
  dockerfile-inline = <<EOF
    FROM ${IMG}:unsafe-${RELEASE}
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
