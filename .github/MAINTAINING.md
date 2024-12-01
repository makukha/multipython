# Maintainer Notes

Images are expected to be updated in theese cases:

* Pyenv is updated, e.g. new Python version is released.
* Critical bug is found in `makukha/multipython:pyenv`.
* Security issue in base Docker image or `makukha/multipython:pyenv` dependencies is fixed.

In all these cases, all images are rebuilt from ground up.

```shell
$ task clean
$ task build
$ task test
$ task version
```

```shell
$ task release
```
