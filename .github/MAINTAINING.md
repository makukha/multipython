# Maintainer Notes

## Check for updated dependencies

```shell
$ task checkupd
```

Images are expected to be updated in these cases:

* Base image `debian:stable-slim` is updated.
* Pyenv is updated, e.g. new Python version is released.
* Critical bug is found in `makukha/multipython:pyenv`.

In all these cases, all images are rebuilt from ground up.

## Update Python versions

### Patch

* `docker-bake.hcl`
* `README.md`
* `dockerhub.md`


## Build

```shell
$ task lint
$ task clean
$ task build
$ task test
$ task version
```

## Release

```shell
$ task release
```
