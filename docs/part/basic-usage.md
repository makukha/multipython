```shell
docker pull makukha/multipython@latest
```

<!-- docsub: begin -->
<!-- docsub: include tests/test_readme_basic/tox.ini -->
<!-- docsub: lines after 2 upto -1 -->
```ini
# tox.ini
[tox]
env_list = py{27,35,36,37,38,39,310,311,312,313,314,313t,314t}
[testenv]
command = {env_python} --version
```
<!-- docsub: end -->

```shell
docker run --rm -v .:/src makukha/multipython tox run --root /src
```

Single version images have tox installed and can be used on their own:
```shell
$ docker run --rm -v .:/src makukha/multipython:py38 tox run --root /src
```
