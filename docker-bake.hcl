variable "IMG" { default = "makukha/multipython" }
variable "RELEASE" { default = "2024.12.19" }

variable "PYENV_VERSION" { default = "2.5.0" }
variable "PYENV_SHA256" { default = "12c42bdaf3741895ad710a957d44dc2b0c5260f95f857318a6681981fe1b1c0b" }
variable "UV_VERSION" { default = "0.5.12" }
variable "UV_SHA256" { default = "65b8dcf3f3e592887fae0daf1b3a9e3aad1262f74bb21cf80d1700c7caba7f23" }

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
