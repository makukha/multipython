variable "IMG" { default = "makukha/multipython" }
variable "RELEASE" { default = "2024.12.19" }

variable "DEBIAN_DIGEST" { default = "sha256:4d63ef53faef7bd35c92fbefb1e9e2e7b6777e3cbec6c34f640e96b925e430eb" }
variable "PYENV_VERSION" { default = "2.4.23" }
variable "PYENV_SHA256" { default = "6578cd1aaea1750632ebeec74c0102919c887a77f7e957e1ed41fab3556e1b4b" }

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


# --- build

group "default" {
  targets = ["base", "py", "final"]
}

target "base_versions" {
  args = {
    DEBIAN_DIGEST = DEBIAN_DIGEST
    PYENV_VERSION = PYENV_VERSION
    PYENV_SHA256 = PYENV_SHA256
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
  args = PY
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
    "test-readme",
    "test-tox",
  ]
}

target "test-base" {
  target = "test-base"
  args = { RELEASE = RELEASE }
  context = "tests"
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
