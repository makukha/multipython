variable "IMG" { default = "makukha/multipython" }
variable "RELEASE" { default = "2024.12.27" }

variable "PYENV_VERSION" { default = "2.5.0" }
variable "PYENV_SHA256" { default = "12c42bdaf3741895ad710a957d44dc2b0c5260f95f857318a6681981fe1b1c0b" }
variable "UV_VERSION" { default = "0.5.13" }
variable "UV_SHA256" { default = "0127da50d3c361d094545aab32921bbce856b3fcc24f1d10436a6426b3f16330" }

variable "PY" {
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

variable "STABLE_TARGET" { default = "py313" }


# --- build

group "default" {
  targets = ["base", "py", "stable", "final"]
}

target "base_versions" {
  args = {
    PYENV_VERSION = PYENV_VERSION
    PYENV_SHA256 = PYENV_SHA256
    UV_VERSION = UV_VERSION
    UV_SHA256 = UV_SHA256
  }
  platforms = ["linux/amd64"]
}

target "base" {
  inherits = ["base_versions"]
  target = "base"
  tags = [
    "${IMG}:base",
    "${IMG}:base-${RELEASE}",
  ]
}

target "py" {
  inherits = ["base_versions"]
  args = { LONG = PY[TAG] }
  matrix = {
    TAG = keys(PY)
  }
  name = TAG
  target = TAG
  tags = [
    "${IMG}:${TAG}",
    "${IMG}:${TAG}-${RELEASE}",
  ]
}

target "stable" {
  inherits = ["base_versions"]
  target = STABLE_TARGET
  args = { LONG = PY[STABLE_TARGET] }
  tags = [
    "${IMG}:stable",
    "${IMG}:stable-${RELEASE}",
  ]
}

target "final" {
  inherits = ["base_versions"]
  args = PY
  target = "final"
  tags = [
    "${IMG}:latest",
    "${IMG}:${RELEASE}",
  ]
}


# --- test

group "test" {
  targets = [
    "test-base",
    "test-final",
    "test-readme-basic",
    "test-readme-advanced",
    "test-tox",
  ]
}

target "test-base" {
  target = "test-base"
  context = "tests"
  args = { RELEASE = RELEASE }
  output = ["type=cacheonly"]
}

target "test-final" {
  target = "test-final"
  args = { RELEASE = RELEASE }
  context = "tests"
  output = ["type=cacheonly"]
}

target "test-readme" {
  args = { RELEASE = RELEASE }
  context = "tests"
  matrix = {
    TARGET = [
      "test-readme-basic",
      "test-readme-advanced",
    ]
  }
  name = TARGET
  output = ["type=cacheonly"]
  target = TARGET
}

target "test-tox" {
  args = { RELEASE = RELEASE }
  context = "tests"
  matrix = {
    TARGET = [
      "test-tox-36",
      "test-tox-37",
      "test-tox-38",
    ]
  }
  name = TARGET
  output = ["type=cacheonly"]
  target = TARGET
}
