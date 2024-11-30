variable "IMG" { default = "makukha/multipython" }
variable "RELEASE" { default = "2024.11.30" }

variable "PYENV_VERSION" { default = "2.4.19" }
variable "PYENV_SHA256" { default = "ce0c441c591bd9960a04bd361d25d87f909e5afc9f44ef8bb283fa67c7ad426e" }

variable "PY" {
  default = {
    py27 = "2.7.18"
    py35 = "3.5.10"
    py36 = "3.6.15"
    py37 = "3.7.17"
    py38 = "3.8.20"
    py39 = "3.9.20"
    py310 = "3.10.15"
    py311 = "3.11.10"
    py312 = "3.12.7"
    py313 = "3.13.0"
    py314 = "3.14.0a2"
    # free threaded
    py313t = "3.13.0t"
    py314t = "3.14.0a2t"
  }
}

# targets

target "base" {
  args = {
    PYENV_VERSION = PYENV_VERSION
  }
  platforms = ["linux/amd64"]
}

target "pyenv" {
  inherits = ["base"]
  args = {
    PYENV_SHA256 = PYENV_SHA256
    TOX_VERSION = "4.5.1.1"
    VIRTUALENV_VERSION = "20.21.1"
  }
  target = "pyenv"
  tags = [
    "${IMG}:pyenv",
    "${IMG}:pyenv-${PYENV_VERSION}",
  ]
}

target "py" {
  inherits = ["base"]
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

target "multipython" {
  inherits = ["base"]
  args = PY
  target = "multipython"
  tags = [
    "${IMG}:latest",
    "${IMG}:${RELEASE}",
  ]
}

# tests

target "tests" {
  args = PY
  dockerfile = "tests.dockerfile"
  matrix = {
    TGT = [
      "test_final",
      "test_readme_example_1",
      "test_readme_example_2",
      "test_readme_example_3",
    ]
  }
  name = TGT
  output = ["type=cacheonly"]
  target = TGT
}
