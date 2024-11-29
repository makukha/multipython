variable "IMG" { default = "makukha/multipython" }
variable "RELEASE" { default = "20241129-dev" }

variable "BASE" {
  default = {
    PYENV_VERSION = "2.4.19"
    PYENV_SHA256 = "ce0c441c591bd9960a04bd361d25d87f909e5afc9f44ef8bb283fa67c7ad426e"
    TOX_VERSION = "4.5.1.1"
    VIRTUALENV_VERSION = "20.21.1"
  }
}

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

group "base" {
  targets = ["pyenv", "tox"]
}

target "pyenv" {
  args = BASE
  platforms = ["linux/amd64"]
  target = "pyenv"
  tags = [
    "${IMG}:pyenv-${BASE["PYENV_VERSION"]}",
    "${IMG}:pyenv",
  ]
}

target "tox" {
  inherits = ["pyenv"]
  target = "tox"
  tags = [
    "${IMG}:tox-${BASE["TOX_VERSION"]}",
    "${IMG}:tox",
  ]
}

target "py" {
  args = "${merge(BASE, PY)}"
  matrix = {
    TAG = keys(PY)
  }
  name = TAG
  platforms = ["linux/amd64"]
  target = "${TAG}"
  tags = [
    "${IMG}:${TAG}-${RELEASE}",
    "${IMG}:${TAG}",
  ]
}

target "final" {
  args = "${merge(BASE, PY)}"
  platforms = ["linux/amd64"]
  target = "final"
  tags = [
    "${IMG}:${RELEASE}",
    "${IMG}:latest",
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
}
