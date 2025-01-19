# Changelog

All notable changes to this project will be documented in this file. Changes for the *upcoming release* can be found in [News directory](https://github.com/makukha/multipython/tree/main/NEWS.d).

* This project adheres to [Date62](http://github.com/date62/date62-python) based [Calendar Versioning](https://calver.org).
* The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

<!-- towncrier release notes start -->

## [v251E](https://github.com/makukha/multipython/releases/tag/v251E) — 2025-01-14

### Breaking 🔥

- System Python is now provided through separate virtual environment, keeping respective original tag distribution untouched ([#76](https://github.com/makukha/multipython/issues/76))

### Added 🌿

- Helper utility command `py tag <executable>` ([#59](https://github.com/makukha/multipython/issues/59))
- [tox-multipython](https://github.com/makukha/tox-multipython) plugin for interpreter discovery with tox 3 ([#70](https://github.com/makukha/multipython/issues/70))
- New JSON metadata key `system`, containing information about system Python environment ([#76](https://github.com/makukha/multipython/issues/76))

### Changed

- Updated base Debian image ([#81](https://github.com/makukha/multipython/issues/81))
- Updated uv to v0.5.18 ([#77](https://github.com/makukha/multipython/issues/77))
- Updated virtualenv-multipython to v0.3.1 ([#72](https://github.com/makukha/multipython/issues/72))

### Docs

- It is now not necessary to have pulled Docker images to update docs ([#54](https://github.com/makukha/multipython/issues/54))
- Updated image digests formatting ([#55](https://github.com/makukha/multipython/issues/55))

### Misc

- Added tests for single version images ([#53](https://github.com/makukha/multipython/issues/53))
- Tests made more robust ([#71](https://github.com/makukha/multipython/issues/71))
- Refactored `py` to use separate command modules under the hood ([#76](https://github.com/makukha/multipython/issues/76))
- Improved Docker layer structure ([#76](https://github.com/makukha/multipython/issues/76))
- Re-implemented Bash documentation scripts in Python ([#79](https://github.com/makukha/multipython/issues/79))
- Started checking docsubfile.py with mypy and ruff ([#79](https://github.com/makukha/multipython/issues/79))


## [v2517](https://github.com/makukha/multipython/releases/tag/v2517) — 2025-01-07

Prepare for multi-source (pyenv + uv) and multi-implementation (PyPy, RustPython, Jython, ...) releases.

### Security ⚠️

- [Pip](https://pip.pypa.io) and [setuptools](https://setuptools.pypa.io) are now updated on every image build to latest compatible version ([#29](https://github.com/makukha/multipython/issues/29))
- Every release now contains image digests to help building reproducible images for secure environments ([#50](https://github.com/makukha/multipython/issues/50))
- 🔥 End-of-life distributions moved under tag `unsafe` to keep `latest` clean and be explicit on security vulnerabilities ([#51](https://github.com/makukha/multipython/issues/51))

### Breaking 🔥

- Changed commands and options of `py` helper utility  ([#36](https://github.com/makukha/multipython/issues/36), [#37](https://github.com/makukha/multipython/issues/37), [#38](https://github.com/makukha/multipython/issues/38), [#39](https://github.com/makukha/multipython/issues/39), [#40](https://github.com/makukha/multipython/issues/40), [#42](https://github.com/makukha/multipython/issues/42), [#43](https://github.com/makukha/multipython/issues/43), [#44](https://github.com/makukha/multipython/issues/44), [#46](https://github.com/makukha/multipython/issues/46))
- Changed versioning scheme to [Date62](http://github.com/date62/date62-python) based CalVer ([#48](https://github.com/makukha/multipython/issues/48)).

### Added 🌿

- Changelog, managed by [towncrier](https://towncrier.readthedocs.io) ([#31](https://github.com/makukha/multipython/issues/31))
- Versions info in JSON with `py info` ([#33](https://github.com/makukha/multipython/issues/33))
- [Tox](http://tox.wiki) is installed in all single version images ([#40](https://github.com/makukha/multipython/issues/40))
- Add tag `cpython` to single-version image with latest bugfix CPython ([#41](https://github.com/makukha/multipython/issues/41))
- Virtualenv plugin [virtualenv-multipython](https://github.com/makukha/virtualenv-multipython) to resolve Python executable from tox env names (`py31{3,4}t` are not covered by tox, more to be added) ([#47](https://github.com/makukha/multipython/issues/47))
- New image tag `supported`, containing all non-EOL non-pre-release distributions ([#49](https://github.com/makukha/multipython/issues/49))

### Changed

- Updated uv to 0.5.15 ([#29](https://github.com/makukha/multipython/issues/29))

### Docs

- Added "Versions" section to README ([#29](https://github.com/makukha/multipython/issues/29))
- Started using [docsub](https://github.com/makukha/docsub) to maintain docs ([#32](https://github.com/makukha/multipython/issues/32))

### Misc

- Removed personal helpers ([#29](https://github.com/makukha/multipython/issues/29))
- Use locally cached version info in `checkupd` ([#30](https://github.com/makukha/multipython/issues/30), [#34](https://github.com/makukha/multipython/issues/34))
- Refactored tests for better availability to [docsub](https://github.com/makukha/docsub) ([#35](https://github.com/makukha/multipython/issues/35))
