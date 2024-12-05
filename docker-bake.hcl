variable "IMG" { default = "makukha/multipython" }
variable "RELEASE" { default = "2024.12.1" }

variable "BASE_DIGEST" { default = "sha256:4d63ef53faef7bd35c92fbefb1e9e2e7b6777e3cbec6c34f640e96b925e430eb" }
variable "PYENV_VERSION" { default = "2.4.20" }
variable "PYENV_SHA256" { default = "a1d6b1bdd92fcfa8fcd98a426545832b00e8e44312ffec76526d89f4c8e3a2a3" }
variable "TOX_VERSION" { default = "4.5.1.1" }
variable "VIRTUALENV_VERSION" { default = "20.21.1" }

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
    py314 = "3.14.0a2"
    # free threaded
    py313t = "3.13.1t"
    py314t = "3.14.0a2t"
  }
}

# targets

target "base" {
  args = {
    BASE_DIGEST = BASE_DIGEST
    PYENV_VERSION = PYENV_VERSION
    PYENV_SHA256 = PYENV_SHA256
    TOX_VERSION = TOX_VERSION
    VIRTUALENV_VERSION = VIRTUALENV_VERSION
  }
  platforms = ["linux/amd64"]
}

target "pyenv" {
  inherits = ["base"]
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
