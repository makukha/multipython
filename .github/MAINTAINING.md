# Maintainer Notes

## Check for updated dependencies

```shell
$ task checkupd
```

Images are expected to be updated in these cases:

* Base image `debian:stable-slim` is updated.
* Pyenv is updated, e.g. new Python version is released.
* Critical bug is found in `makukha/multipython:base`.

In all these and other cases, all images are rebuilt from ground up.


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
$ task lint clean build test checkupd
$ task release
```
